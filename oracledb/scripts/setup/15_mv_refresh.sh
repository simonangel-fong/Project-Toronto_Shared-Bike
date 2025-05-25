#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     mv_refresh.sh
# Description:     Refreshes materialized views and confirms the operation
#                  by executing SQL scripts.
# Usage:           ./mv_refresh.sh
# Requirements:    Must be run by a user with SYSDBA privileges.
# -----------------------------------------------------------------------------

# Execute SQL scripts to refresh and confirm materialized views
sqlplus -s / as sysdba <<EOF

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

exit
EOF
