-- ============================================================================
-- Script Name : 09_create_mv.sql
-- Purpose     : Create materialized view logs and materialized views for efficient
--               querying and reporting in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with appropriate privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the DW_SCHEMA, fact, and dimension tables are created and populated
-- ============================================================================

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- Create materialized view log on fact_trip for fast refresh support
CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.fact_trip
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    fact_trip_start_time_id
    , fact_trip_start_station_id
    , fact_trip_end_station_id
    )
INCLUDING NEW VALUES;

-- Create materialized view log on dim_time for fast refresh support
CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.dim_time
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    dim_time_id
    , dim_time_year
    , dim_time_quarter
    , dim_time_month
    , dim_time_day
    , dim_time_week
    , dim_time_weekday
    , dim_time_hour
    )
INCLUDING NEW VALUES;

-- Create materialized view log on dim_station for fast refresh support
CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.dim_station
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    dim_station_id
    , dim_station_name
    )
INCLUDING NEW VALUES;

-- Create materialized view for time-based trip analysis
CREATE MATERIALIZED VIEW DW_SCHEMA.MV_TIME_TRIP
TABLESPACE MV_TBSP
PARTITION BY RANGE (dim_year) (
    PARTITION p_before  VALUES LESS THAN (2019)  -- Partition for pre-2019 data
    , PARTITION p_2020  VALUES LESS THAN (2020)  -- Partition for 2020 data
    , PARTITION p_2021  VALUES LESS THAN (2021)  -- Partition for 2021 data
    , PARTITION p_2022  VALUES LESS THAN (2022)  -- Partition for 2022 data
    , PARTITION p_2023  VALUES LESS THAN (2023)  -- Partition for 2023 data
    , PARTITION p_2024  VALUES LESS THAN (2024)  -- Partition for 2024 data
    , PARTITION p_2025  VALUES LESS THAN (2025)  -- Partition for 2025 data
    , PARTITION p_max   VALUES LESS THAN (MAXVALUE)  -- Catch-all partition
)
BUILD IMMEDIATE
REFRESH FAST ON DEMAND  -- Enable incremental updates
ENABLE QUERY REWRITE
AS
SELECT
    COUNT(*)                AS trip_count
    , t.dim_time_year       AS dim_year
    , t.dim_time_quarter    AS dim_quarter
    , t.dim_time_month      AS dim_month
    , t.dim_time_day        AS dim_day
    , t.dim_time_week       AS dim_week
    , t.dim_time_weekday    AS dim_weekday
    , t.dim_time_hour       AS dim_hour
FROM DW_SCHEMA.fact_trip f
JOIN DW_SCHEMA.dim_time t
    ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
    t.dim_time_year
    , t.dim_time_quarter
    , t.dim_time_month
    , t.dim_time_day
    , t.dim_time_week
    , t.dim_time_weekday
    , t.dim_time_hour;

-- Create composite B-tree index for year-month queries on MV_TIME_TRIP
CREATE INDEX DW_SCHEMA.idx_mv_time_trip_year_month
ON DW_SCHEMA.MV_TIME_TRIP (dim_year, dim_month)
TABLESPACE MV_TBSP;

-- Create composite B-tree index for year-hour queries on MV_TIME_TRIP
CREATE INDEX DW_SCHEMA.idx_mv_time_trip_year_hour
ON DW_SCHEMA.MV_TIME_TRIP (dim_year, dim_hour)
TABLESPACE MV_TBSP;

-- Create materialized view for station-based trip analysis
CREATE MATERIALIZED VIEW DW_SCHEMA.MV_STATION_TRIP
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
    s.dim_station_id                                                                AS station_id
    , s.dim_station_name                                                            AS station_name
    , COUNT(CASE WHEN f.fact_trip_start_station_id = s.dim_station_id THEN 1 END)   AS trip_count_by_start
    , COUNT(CASE WHEN f.fact_trip_end_station_id = s.dim_station_id THEN 1 END)     AS trip_count_by_end
FROM DW_SCHEMA.fact_trip f
JOIN DW_SCHEMA.dim_station s
    ON s.dim_station_id IN (f.fact_trip_start_station_id, f.fact_trip_end_station_id)
GROUP BY
    s.dim_station_id
    , s.dim_station_name;

-- Create materialized view for station route analysis
CREATE MATERIALIZED VIEW DW_SCHEMA.MV_STATION_ROUTE
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
    s_start.dim_station_id      AS start_station_id
    , s_start.dim_station_name  AS start_station_name
    , s_end.dim_station_id      AS end_station_id
    , s_end.dim_station_name    AS end_station_name
    , COUNT(*)                  AS trip_count
FROM DW_SCHEMA.fact_trip f
JOIN DW_SCHEMA.dim_station s_start
    ON f.fact_trip_start_station_id = s_start.dim_station_id
JOIN DW_SCHEMA.dim_station s_end
    ON f.fact_trip_end_station_id = s_end.dim_station_id
GROUP BY
    s_start.dim_station_id
    , s_start.dim_station_name
    , s_end.dim_station_id
    , s_end.dim_station_name;

-- Create materialized view for bike trip duration analysis
CREATE MATERIALIZED VIEW DW_SCHEMA.MV_BIKE_TRIP_DURATION
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
    b.dim_bike_id                           AS bike_id
    , COUNT(*)                              AS trip_count
    , ROUND(AVG(f.fact_trip_duration), 2)   AS avg_trip_duration
FROM DW_SCHEMA.fact_trip f
JOIN DW_SCHEMA.dim_bike b
    ON f.fact_trip_bike_id = b.dim_bike_id
GROUP BY
    b.dim_bike_id;

-- Create materialized view for user segmentation analysis
CREATE MATERIALIZED VIEW DW_SCHEMA.MV_USER_SEGMENTATION
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
    u.dim_user_type_id                      AS user_type_id
    , u.dim_user_type_name                  AS user_type_name
    , t.dim_time_year                       AS dim_year
    , COUNT(*)                              AS trip_count
    , ROUND(AVG(f.fact_trip_duration),2)    AS avg_trip_duration
FROM DW_SCHEMA.fact_trip f
JOIN DW_SCHEMA.dim_user_type u
    ON f.fact_trip_user_type_id = u.dim_user_type_id
JOIN DW_SCHEMA.dim_time t
    ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
    u.dim_user_type_id
    , u.dim_user_type_name
    , t.dim_time_year;