-- ============================================================================
-- Script Name : apiquery.sql
-- Purpose     : 
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : 
-- Notes       : 
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- ============================================================================
-- Analysis: mv_time_trip
-- ============================================================================
SELECT *
FROM dw_schema.mv_time_trip
ORDER BY dim_year DESC, dim_month DESC, dim_day DESC, dim_hour DESC;

-- ============================================================================
-- Analysis: mv_bike_trip_duration
-- ============================================================================
SELECT *
FROM dw_schema.mv_bike_trip_duration
ORDER BY trip_count DESC, avg_trip_duration DESC;

-- ============================================================================
-- Analysis: mv_station_route
-- ============================================================================
SELECT *
FROM dw_schema.mv_station_route
ORDER BY trip_count DESC;

-- ============================================================================
-- Analysis: mv_station_trip
-- ============================================================================
SELECT *
FROM dw_schema.mv_station_trip
ORDER BY trip_count_by_start DESC, trip_count_by_end DESC;

-- ============================================================================
-- Analysis: mv_user_segmentation
-- ============================================================================
SELECT *
FROM dw_schema.mv_user_segmentation
ORDER BY user_type_name ASC, dim_year ASC;

TRUNCATE TABLE dw_schema.fact_trip;
TRUNCATE TABLE dw_schema.dim_time;
TRUNCATE TABLE dw_schema.dim_station;
TRUNCATE TABLE dw_schema.dim_bike;
TRUNCATE TABLE dw_schema.dim_user_type;

commit;


