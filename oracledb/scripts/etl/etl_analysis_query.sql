-- ============================================================================
-- Script Name : 000_analysis_query.sql
-- Purpose     : 
-- Author      : Wenhao Fang
-- Date        : 2025-05-08
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
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

DESC dw_schema.staging_trip
--Name               Null? Type          
-------------------- ----- ------------- 
--TRIP_ID                  VARCHAR2(15)  
--TRIP_DURATION            VARCHAR2(15)  
--START_TIME               VARCHAR2(50)  
--START_STATION_ID         VARCHAR2(15)  
--START_STATION_NAME       VARCHAR2(100) 
--END_TIME                 VARCHAR2(50)  
--END_STATION_ID           VARCHAR2(15)  
--END_STATION_NAME         VARCHAR2(100) 
--BIKE_ID                  VARCHAR2(15)  
--USER_TYPE                VARCHAR2(50)  
--MODEL                    VARCHAR2(50)  

-- ============================================================================
-- time dimension table
-- ============================================================================
SELECT 
    *
--    COUNT(*)
FROM DW_SCHEMA.dim_time
ORDER BY 
    dim_time_id DESC;

-- ============================================================================
-- station dimension table
-- ============================================================================
SELECT 
    *
--    COUNT(*)
FROM DW_SCHEMA.dim_station
ORDER BY dim_station_id;

-- ============================================================================
-- bike dimension table
-- ============================================================================
SELECT 
    *
--    COUNT(*)
FROM DW_SCHEMA.dim_bike
ORDER BY dim_bike_id DESC;

-- ============================================================================
-- user type dimension table
-- ============================================================================
SELECT 
    *
--    COUNT(*)
FROM DW_SCHEMA.dim_user_type;

-- ============================================================================
-- trip fact table
-- ============================================================================
SELECT COUNT(*)
FROM DW_SCHEMA.fact_trip;

-- ============================================================================
-- full
-- ============================================================================
SELECT *
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time stim
ON f.fact_trip_start_time_id = stim.dim_time_id
JOIN dw_schema.dim_time etim
ON f.fact_trip_end_time_id = etim.dim_time_id
JOIN dw_schema.dim_station stst
ON f.fact_trip_start_station_id = stst.dim_station_id 
JOIN dw_schema.dim_station enst
ON f.fact_trip_start_station_id = enst.dim_station_id
JOIN dw_schema.dim_bike bk
ON f.fact_trip_bike_id = bk.dim_bike_id
JOIN dw_schema.dim_user_type ustp
ON f.fact_trip_user_type_id = ustp.dim_user_type_id
--WHERE ROWNUM < 5
ORDER BY fact_trip_start_time_id DESC;
