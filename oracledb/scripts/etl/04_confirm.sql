-- ============================================================================
-- Script Name : 04_confirm.sql
-- Purpose     : Verify the data loaded into the dimension and fact tables
--               by counting the number of records in each table
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Run this script after the transformation and loading steps to confirm data counts
-- ============================================================================

-- Enable server output for debugging or messages
SET SERVEROUTPUT ON;

-- Switch to the application PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- Count the number of records in the time dimension table
SELECT COUNT(*)
FROM DW_SCHEMA.dim_time;

-- Count the number of records in the station dimension table
SELECT COUNT(*)
FROM DW_SCHEMA.dim_station;

-- Count the number of records in the bike dimension table
SELECT COUNT(*)
FROM DW_SCHEMA.dim_bike;

-- Count the number of records in the user type dimension table
SELECT COUNT(*)
FROM DW_SCHEMA.dim_user_type;

-- Count the number of records in the trip fact table
SELECT COUNT(*)
FROM DW_SCHEMA.fact_trip;