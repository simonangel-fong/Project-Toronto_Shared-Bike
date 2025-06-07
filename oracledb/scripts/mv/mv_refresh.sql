-- ============================================================================
-- Script Name : mv_refresh.sql
-- Purpose     : Refresh materialized views in the Data Warehouse to update 
--               aggregated data for reporting and analysis
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure all dimension and fact tables are populated before refreshing materialized views
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
-- Refreshing the time-based trip materialized view using fast refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_trip_time', 'F');

-- ============================================================================
-- Refreshing the time-based duration materialized view using complete refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_duration_time', 'C');

-- ============================================================================
-- Refreshing the station trip materialized view using fast refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_trip_station', 'F');

-- ============================================================================
-- Refreshing the user type materialized view using complete refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_user_type', 'C');

COMMIT;