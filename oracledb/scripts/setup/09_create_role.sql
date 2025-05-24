-- ============================================================================
-- Script Name : create_role.sql
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
CREATE ROLE roleAPIUser;

-- Grant SELECT privileges on materialized views to the role
GRANT SELECT ON dw_schema.mv_user_segmentation TO roleAPIUser;
GRANT SELECT ON dw_schema.mv_time_trip TO roleAPIUser;
GRANT SELECT ON dw_schema.mv_station_trip TO roleAPIUser;
GRANT SELECT ON dw_schema.mv_station_route TO roleAPIUser;
GRANT SELECT ON dw_schema.mv_bike_trip_duration TO roleAPIUser;

GRANT connect TO roleAPIUser;

-- ========================================================
-- Create a role for data analysis
-- ========================================================
CREATE ROLE roleDataAnalysis;

-- Grant SELECT privileges on data warehouse to the role
GRANT SELECT ON dw_schema.fact_trip TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_time TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_station TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_bike TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_user_type TO roleDataAnalysis;

-- Grant SELECT privileges on materialized views to the role
GRANT SELECT ON dw_schema.mv_user_segmentation TO roleDataAnalysis;
GRANT SELECT ON dw_schema.mv_time_trip TO roleDataAnalysis;
GRANT SELECT ON dw_schema.mv_station_trip TO roleDataAnalysis;
GRANT SELECT ON dw_schema.mv_station_route TO roleDataAnalysis;
GRANT SELECT ON dw_schema.mv_bike_trip_duration TO roleDataAnalysis;

GRANT connect TO roleDataAnalysis;

-- ========================================================
-- Create a role for data engineer
-- ========================================================
CREATE ROLE roleDataEngineer;

GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.staging_trip TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.fact_trip TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_time TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_station TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_bike TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_user_type TO roleDataEngineer;

GRANT connect, resource TO roleDataEngineer;

-- ========================================================
-- Confirm
-- ========================================================
SELECT 
    role
    , password_required
FROM dba_roles
WHERE role IN ('ROLEAPIUSER','ROLEDATAANALYSIS', 'ROLEDATAENGINEER');
