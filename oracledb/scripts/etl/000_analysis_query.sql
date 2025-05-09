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


-- TRIP_ID
SELECT DISTINCT trip_id
FROM dw_schema.staging_trip
ORDER BY 1 DESC;

-- START_STATION_NAME
SELECT COUNT(DISTINCT START_STATION_NAME)
FROM dw_schema.staging_trip;


SELECT COUNT(DISTINCT station)
FROM (
    SELECT START_STATION_NAME AS Station
    FROM dw_schema.staging_trip
    UNION
    SELECT START_STATION_NAME AS Station
    FROM dw_schema.staging_trip
    )
ORDER BY station;
