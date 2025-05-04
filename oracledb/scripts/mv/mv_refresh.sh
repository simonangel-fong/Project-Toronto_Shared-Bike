#!/bin/bash

# Script: sh01_refresh.sh
# Purpose: Execute SQL to refresh materialized view.
# Usage: ./sh01_refresh.sh

sqlplus / as sysdba<<EOF
@/project/scripts/mv/01refresh.sql
@/project/scripts/mv/02confirm.sql
exit
EOF
