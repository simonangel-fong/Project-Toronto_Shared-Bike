-- ============================================================================
-- Script Name : 10_create_user.sql
-- Purpose     : Create a role for access to materialized views and data warehouse
--               in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the dw_schema and materialized views are created before running
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- ========================================================
-- Create a role for API users
-- ========================================================
CREATE ROLE apiUserRole;

-- Grant SELECT privileges on materialized views to the role
GRANT SELECT ON dw_schema.mv_user_segmentation TO apiUserRole;
GRANT SELECT ON dw_schema.mv_time_trip TO apiUserRole;
GRANT SELECT ON dw_schema.mv_station_trip TO apiUserRole;
GRANT SELECT ON dw_schema.mv_station_route TO apiUserRole;
GRANT SELECT ON dw_schema.mv_bike_trip_duration TO apiUserRole;
-- GRANT SELECT ON dw_schema.mv_trip_summary TO apiUserRole;

-- ========================================================
-- Create a role for data analysis
-- ========================================================
CREATE ROLE dataAnalysis;

-- Grant SELECT privileges on data warehouse to the role
GRANT SELECT ON dw_schema.fact_trip TO dataAnalysis;
GRANT SELECT ON dw_schema.dim_time TO dataAnalysis;
GRANT SELECT ON dw_schema.dim_station TO dataAnalysis;
GRANT SELECT ON dw_schema.dim_bike TO dataAnalysis;
GRANT SELECT ON dw_schema.dim_user_type TO dataAnalysis;

-- Grant SELECT privileges on materialized views to the role
GRANT SELECT ON dw_schema.mv_user_segmentation TO dataAnalysis;
GRANT SELECT ON dw_schema.mv_time_trip TO dataAnalysis;
GRANT SELECT ON dw_schema.mv_station_trip TO dataAnalysis;
GRANT SELECT ON dw_schema.mv_station_route TO dataAnalysis;
GRANT SELECT ON dw_schema.mv_bike_trip_duration TO dataAnalysis;
-- GRANT SELECT ON dw_schema.mv_trip_summary TO dataAnalysis;

-- ========================================================
-- Confirm
-- ========================================================
SELECT 
    role
    , password_required
FROM dba_roles
WHERE role IN ('APIUSERROLE','DATAANALYSIS');
