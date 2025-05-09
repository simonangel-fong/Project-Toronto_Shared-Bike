-- ============================================================================
-- Script Name : 10_create_user.sql
-- Purpose     : Create a role and user for API access to materialized views
--               in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the DW_SCHEMA and materialized views are created before running
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- Create a role for API testers
CREATE ROLE apiUserRole;

-- Grant SELECT privileges on materialized views to the role
GRANT SELECT ON DW_SCHEMA.MV_USER_SEGMENTATION TO apiUserRole;
GRANT SELECT ON DW_SCHEMA.MV_TIME_TRIP TO apiUserRole;
GRANT SELECT ON DW_SCHEMA.MV_STATION_TRIP TO apiUserRole;
GRANT SELECT ON DW_SCHEMA.MV_STATION_ROUTE TO apiUserRole;
GRANT SELECT ON DW_SCHEMA.MV_BIKE_TRIP_DURATION TO apiUserRole;

-- Create the API user with a secure password
CREATE USER apiApp IDENTIFIED BY "SecurePassword!23";

-- Grant session creation and the API role to the user
GRANT create session, apiUserRole TO apiApp;


SELECT 
    role
    , password_required
FROM dba_roles
WHERE role = 'APIUSERROLE';

SELECT 
    username
    , account_status
FROM dba_users
WHERE username = 'APIAPP';