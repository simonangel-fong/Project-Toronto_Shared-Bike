-- ============================================================================
-- Script Name : 02confirm.sql
-- Purpose     : Query materialized views to retrieve top records for analysis
--               and reporting purposes
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure materialized views are refreshed before running this script
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- time-based trip materialized view
SELECT *
FROM dw_schema.mv_time_trip
ORDER BY dim_year DESC, dim_month DESC, dim_day DESC, dim_hour DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the station-based trip materialized view
SELECT *
FROM dw_schema.mv_station_trip
ORDER BY trip_count_by_start DESC, trip_count_by_end DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the station route materialized view
SELECT * 
FROM dw_schema.mv_station_route
ORDER BY trip_count DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the bike trip duration materialized view
SELECT *
FROM dw_schema.mv_bike_trip_duration
ORDER BY trip_count DESC, avg_trip_duration DESC
FETCH FIRST 10 ROWS ONLY;

-- Query the user segmentation materialized view
SELECT *
FROM DW_SCHEMA.MV_USER_SEGMENTATION
ORDER BY user_type_name ASC, dim_year ASC
FETCH FIRST 10 ROWS ONLY;
