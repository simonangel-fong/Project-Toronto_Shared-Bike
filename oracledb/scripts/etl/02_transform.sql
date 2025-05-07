-- ============================================================================
-- Script Name : 02_transform.sql
-- Purpose     : Clean and transform data in the staging table before loading into the Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure the staging table `dw_schema.staging_trip` has data loaded before running
-- ============================================================================

-- Enable server output for debugging or messages
SET SERVEROUTPUT ON;

-- Switch to the application PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- ============================================================================
-- Step 1: Remove rows with NULLs in key columns
-- ============================================================================
DELETE FROM DW_SCHEMA.staging_trip
WHERE trip_id IS NULL
  OR trip_duration IS NULL
  OR start_time IS NULL
  OR start_station_id IS NULL
  OR end_station_id IS NULL;

-- Remove rows where station IDs are the string "NULL"
DELETE FROM DW_SCHEMA.staging_trip
WHERE start_station_id = 'NULL'
  OR end_station_id = 'NULL';

COMMIT;

-- ============================================================================
-- Step 2: Remove rows with invalid data types or formats
-- ============================================================================
DELETE FROM DW_SCHEMA.staging_trip
WHERE
  -- trip_id must be numeric
  NOT REGEXP_LIKE(trip_id, '^[0-9]+$')
  -- trip_duration must be a valid number
  OR NOT REGEXP_LIKE(trip_duration, '^[0-9]+(\.[0-9]+)?$')
  -- start_time must follow MM/DD/YYYY HH24:MI
  OR NOT REGEXP_LIKE(start_time, '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$')
  -- start_time must be a valid date
  OR TO_DATE(start_time, 'MM/DD/YYYY HH24:MI', 'NLS_DATE_LANGUAGE = AMERICAN') IS NULL
  -- station IDs must be numeric
  OR NOT REGEXP_LIKE(start_station_id, '^[0-9]+$')
  OR NOT REGEXP_LIKE(end_station_id, '^[0-9]+$');

COMMIT;

-- ============================================================================
-- Step 3: Remove rows with non-positive trip durations
-- ============================================================================
DELETE FROM DW_SCHEMA.staging_trip
WHERE TO_NUMBER(trip_duration) <= 0;

COMMIT;

-- ============================================================================
-- Step 4: Derive and substitute non-critical columns
-- ============================================================================

-- Derive missing or invalid end_time from start_time and trip_duration
UPDATE DW_SCHEMA.staging_trip
SET end_time = TO_CHAR(
  TO_DATE(start_time, 'MM/DD/YYYY HH24:MI') + (TO_NUMBER(trip_duration) / 86400),
  'MM/DD/YYYY HH24:MI'
)
WHERE end_time IS NULL
   OR NOT REGEXP_LIKE(end_time, '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$')
   OR TO_DATE(end_time, 'MM/DD/YYYY HH24:MI', 'NLS_DATE_LANGUAGE = AMERICAN') IS NULL;

COMMIT;

-- Substitute missing station names with 'UNKNOWN'
UPDATE DW_SCHEMA.staging_trip
SET start_station_name = 'UNKNOWN',
    end_station_name = 'UNKNOWN'
WHERE start_station_name IS NULL
   OR end_station_name IS NULL;

COMMIT;

-- Substitute missing user_type with 'UNKNOWN'
UPDATE DW_SCHEMA.staging_trip
SET user_type = 'UNKNOWN'
WHERE user_type IS NULL;

COMMIT;

-- Substitute invalid or missing bike_id with '-1'
UPDATE DW_SCHEMA.staging_trip
SET bike_id = '-1'
WHERE bike_id IS NULL
   OR (NOT REGEXP_LIKE(bike_id, '^[0-9]+$') AND bike_id != '-1');

COMMIT;

-- Substitute missing model with 'UNKNOWN'
UPDATE DW_SCHEMA.staging_trip
SET model = 'UNKNOWN'
WHERE model IS NULL;

COMMIT;
