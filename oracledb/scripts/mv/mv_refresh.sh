#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     mv_refresh.sh
# Description:     Refreshes materialized views and confirms the operation
#                  by executing SQL scripts.
# Usage:           ./mv_refresh.sh
# Requirements:    Must be run by a user with SYSDBA privileges.
# -----------------------------------------------------------------------------

# Execute SQL scripts to refresh and confirm materialized views
sqlplus / as sysdba <<EOF
-- Refresh materialized views
@/project/scripts/mv/mv_refresh.sql
-- Confirm materialized view refresh status
-- @/project/scripts/mv/mv_confirm.sql

exit
EOF
