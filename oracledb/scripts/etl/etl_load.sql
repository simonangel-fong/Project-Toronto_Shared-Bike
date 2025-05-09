-- ============================================================================
-- Script Name : 03_load.sql
-- Purpose     : Perform the Transformation and Loading steps in the ELT process
--               by populating dimension and fact tables from the staging table
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure the staging table is populated before running this script
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- Populate the time dimension table with unique timestamps
MERGE /*+ APPEND */ INTO DW_SCHEMA.dim_time tgt
USING (
  -- Union start_time and end_time to capture all timestamps
  SELECT DISTINCT
    TO_DATE(time_value, 'MM/DD/YYYY HH24:MI') AS timestamp_value
  FROM (
    SELECT start_time AS time_value FROM DW_SCHEMA.staging_trip
    UNION
    SELECT end_time AS time_value FROM DW_SCHEMA.staging_trip
    WHERE end_time IS NOT NULL
  )
) src
ON (tgt.dim_time_timestamp = src.timestamp_value)
WHEN NOT MATCHED THEN
  INSERT (
    dim_time_id,
    dim_time_timestamp,
    dim_time_year,
    dim_time_quarter,
    dim_time_month,
    dim_time_day,
    dim_time_week,
    dim_time_weekday,
    dim_time_hour,
    dim_time_minute
  )
  VALUES (
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'YYYYMMDDHH24MI')), -- Unique ID based on timestamp (YYYYMMDDHHMI)
    src.timestamp_value,                                       -- Full timestamp
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'YYYY')),           -- Extracted year
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'Q')),              -- Extracted quarter (1-4)
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'MM')),             -- Extracted month (1-12)
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'DD')),             -- Extracted day (1-31)
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'IW')),             -- Extracted ISO week (1-53)
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'D')),              -- Extracted weekday (1-7, Sunday=1)
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'HH24')),           -- Extracted hour (0-23)
    TO_NUMBER(TO_CHAR(src.timestamp_value, 'MI'))              -- Extracted minute (0-59)
  );

COMMIT;

-- Populate the station dimension table with unique station information
MERGE INTO DW_SCHEMA.dim_station ds
USING (
    WITH station_times AS (
        -- Collect start station records
        SELECT 
            start_station_id AS station_id,
            start_station_name AS station_name,
            TO_DATE(start_time, 'MM/DD/YYYY HH24:MI') AS trip_datetime
        FROM DW_SCHEMA.staging_trip
        WHERE 
            start_station_id IS NOT NULL 
            AND start_station_name IS NOT NULL
        UNION ALL
        -- Collect end station records
        SELECT 
            end_station_id AS station_id,
            end_station_name AS station_name,
            TO_DATE(end_time, 'MM/DD/YYYY HH24:MI') AS trip_datetime
        FROM DW_SCHEMA.staging_trip
        WHERE end_station_id IS NOT NULL AND end_station_name IS NOT NULL
    ),
    latest_stations AS (
        -- Select the most recent station name for each station ID
        SELECT 
            station_id,
            station_name,
            ROW_NUMBER() OVER (PARTITION BY station_id ORDER BY trip_datetime DESC) AS rn
        FROM station_times
    )
    SELECT 
        station_id AS dim_station_id,
        station_name AS dim_station_name
    FROM latest_stations
    WHERE rn = 1
) src
ON (ds.dim_station_id = src.dim_station_id)
WHEN MATCHED THEN
    UPDATE SET ds.dim_station_name = src.dim_station_name
WHEN NOT MATCHED THEN
    INSERT (ds.dim_station_id, ds.dim_station_name)
    VALUES (src.dim_station_id, src.dim_station_name);

COMMIT;

-- Populate the bike dimension table with unique bike information
MERGE /*+ APPEND */ INTO DW_SCHEMA.dim_bike tgt
USING (
  -- Aggregate bike data, handling unknown models
  SELECT 
    TO_NUMBER(TRIM(bike_id)) AS bike_id,
    COALESCE(
      MAX(CASE WHEN UPPER(TRIM(model)) != 'UNKNOWN' THEN TRIM(REPLACE(model, CHR(13), '')) END),
      'UNKNOWN'
    ) AS bike_model
  FROM DW_SCHEMA.staging_trip
  GROUP BY TO_NUMBER(TRIM(bike_id))
) src
ON (tgt.dim_bike_id = src.bike_id)
WHEN MATCHED THEN
  -- Update bike model if it has changed
  UPDATE SET 
    tgt.dim_bike_model = src.bike_model
  WHERE tgt.dim_bike_model != src.bike_model
WHEN NOT MATCHED THEN
  -- Insert new bike records
  INSERT (dim_bike_id, dim_bike_model)
  VALUES (src.bike_id, src.bike_model);

COMMIT;

-- Populate the user type dimension table with unique user types
MERGE /*+ APPEND */ INTO DW_SCHEMA.dim_user_type tgt
USING (
  -- Select distinct user types
  SELECT DISTINCT user_type AS user_type_name
  FROM DW_SCHEMA.staging_trip
  WHERE user_type IS NOT NULL
) src
ON (tgt.dim_user_type_name = src.user_type_name)
WHEN NOT MATCHED THEN
  -- Insert new user types
  INSERT (
    dim_user_type_name
  )
  VALUES (
    src.user_type_name
  );

-- Commit the changes to the user type dimension
COMMIT;

-- Populate the fact table with trip data
MERGE /*+ APPEND */ INTO DW_SCHEMA.fact_trip tgt
USING (
  -- Transform staging data into fact table format
  SELECT 
    TO_NUMBER(trip_id)                                                                                                  "FACT_TRIP_SOURCE_ID",
    TO_NUMBER(trip_duration)                                                                                            "FACT_TRIP_DURATION",
    (SELECT dim_time_id FROM dw_schema.dim_time WHERE dim_time_timestamp = TO_DATE(start_time,'MM/DD/YYYY HH24:MI'))    "FACT_TRIP_START_TIME_ID",
    (SELECT dim_time_id FROM dw_schema.dim_time WHERE dim_time_timestamp = TO_DATE(end_time,'MM/DD/YYYY HH24:MI'))      "FACT_TRIP_END_TIME_ID",
    TO_NUMBER(start_station_id)                                                                                         "FACT_TRIP_START_STATION_ID",
    TO_NUMBER(end_station_id)                                                                                           "FACT_TRIP_END_STATION_ID",
    TO_NUMBER(bike_id)                                                                                                  "FACT_TRIP_BIKE_ID",
    (SELECT dim_user_type_id FROM dw_schema.dim_user_type WHERE dim_user_type_name = user_type)                         "FACT_TRIP_USER_TYPE_ID"
  FROM dw_schema.staging_trip
) src
ON (tgt.fact_trip_source_id = src.FACT_TRIP_SOURCE_ID)
WHEN MATCHED THEN
  -- Update existing trip records if any attributes have changed
  UPDATE SET 
    tgt.fact_trip_duration = src.FACT_TRIP_DURATION,
    tgt.fact_trip_start_time_id = src.FACT_TRIP_START_TIME_ID,
    tgt.fact_trip_end_time_id = src.FACT_TRIP_END_TIME_ID,
    tgt.fact_trip_start_station_id = src.FACT_TRIP_START_STATION_ID,
    tgt.fact_trip_end_station_id = src.FACT_TRIP_END_STATION_ID,
    tgt.fact_trip_bike_id = src.FACT_TRIP_BIKE_ID,
    tgt.fact_trip_user_type_id = src.FACT_TRIP_USER_TYPE_ID
  WHERE tgt.fact_trip_duration != src.FACT_TRIP_DURATION 
     OR tgt.fact_trip_start_time_id != src.FACT_TRIP_START_TIME_ID 
     OR tgt.fact_trip_end_time_id != src.FACT_TRIP_END_TIME_ID 
     OR tgt.fact_trip_start_station_id != src.FACT_TRIP_START_STATION_ID 
     OR tgt.fact_trip_end_station_id != src.FACT_TRIP_END_STATION_ID 
     OR tgt.fact_trip_bike_id != src.FACT_TRIP_BIKE_ID 
     OR tgt.fact_trip_user_type_id != src.FACT_TRIP_USER_TYPE_ID
WHEN NOT MATCHED THEN
  -- Insert new trip records
  INSERT (
    fact_trip_source_id,
    fact_trip_duration,
    fact_trip_start_time_id,
    fact_trip_end_time_id,
    fact_trip_start_station_id,
    fact_trip_end_station_id,
    fact_trip_bike_id,
    fact_trip_user_type_id
  )
  VALUES (
    src.FACT_TRIP_SOURCE_ID,
    src.FACT_TRIP_DURATION,
    src.FACT_TRIP_START_TIME_ID,
    src.FACT_TRIP_END_TIME_ID,
    src.FACT_TRIP_START_STATION_ID,
    src.FACT_TRIP_END_STATION_ID,
    src.FACT_TRIP_BIKE_ID,
    src.FACT_TRIP_USER_TYPE_ID
  );

-- Commit the changes to the fact table
COMMIT;