-- ============================================================================
-- Script Name : 02confirm.sql
-- Purpose     : Query materialized views to retrieve top records for analysis
--               and reporting purposes
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure materialized views are refreshed before running this script
-- ============================================================================

-- Enable server output for debugging or messages
SET SERVEROUTPUT ON;

-- Switch to the application PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- Query the time-based trip materialized view, showing the 10 most recent records by year and month
SELECT *
FROM DW_SCHEMA.MV_TIME_TRIP
ORDER BY DIM_YEAR DESC, DIM_MONTH DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the station-based trip materialized view, showing the top 10 stations by trip count (start station)
SELECT *
FROM DW_SCHEMA.MV_STATION_TRIP
ORDER BY trip_count_by_start DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the station route materialized view, showing the top 10 routes by trip count
SELECT * 
FROM DW_SCHEMA.MV_STATION_ROUTE
ORDER BY trip_count DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the bike trip duration materialized view, showing the top 10 bikes by trip count
SELECT *
FROM DW_SCHEMA.MV_BIKE_TRIP_DURATION
ORDER BY trip_count DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the user segmentation materialized view, showing up to 10 records
SELECT *
FROM DW_SCHEMA.MV_USER_SEGMENTATION
WHERE ROWNUM < 10;