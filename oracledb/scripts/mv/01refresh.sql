-- ============================================================================
-- Script Name : 01refresh.sql
-- Purpose     : Refresh materialized views in the Data Warehouse to update 
--               aggregated data for reporting and analysis
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure all dimension and fact tables are populated before refreshing materialized views
-- ============================================================================

-- Enable server output for debugging or messages
SET SERVEROUTPUT ON;

-- Switch to the application PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- Refresh the time-based trip materialized view using fast refresh
EXEC DBMS_MVIEW.REFRESH('DW_SCHEMA.MV_TIME_TRIP', 'F');
-- Refresh the station-based trip materialized view using complete refresh
EXEC DBMS_MVIEW.REFRESH('DW_SCHEMA.MV_STATION_TRIP', 'C');
-- Refresh the station route materialized view using fast refresh
EXEC DBMS_MVIEW.REFRESH('DW_SCHEMA.MV_STATION_ROUTE', 'F');
-- Refresh the bike trip duration materialized view using complete refresh
EXEC DBMS_MVIEW.REFRESH('DW_SCHEMA.MV_BIKE_TRIP_DURATION', 'C');
-- Refresh the user segmentation materialized view using complete refresh
EXEC DBMS_MVIEW.REFRESH('DW_SCHEMA.MV_USER_SEGMENTATION', 'C');