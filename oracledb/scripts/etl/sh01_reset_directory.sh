#!/bin/bash

# Script: 01reset_directory.sh
# Purpose: Execute SQL to reset directory for a given year in Oracle Database
# Usage: ./01reset_directory.sh [year]
# Default year: 2019 if no parameter is provided

# Set default year to 2019 if no parameter is provided
YEAR=${1:-2019}

# SQL commands to be executed
SQL_COMMANDS=$(cat << 'EOF'
SET SERVEROUTPUT ON;
ALTER SESSION SET CONTAINER = toronto_shared_bike;
CREATE OR REPLACE DIRECTORY dir_target AS '/project/data/$YEAR';
GRANT READ ON DIRECTORY dir_target TO dw_schema;
EXIT;
EOF
)

# Replace $YEAR in SQL commands with the provided year
SQL_COMMANDS=$(echo "$SQL_COMMANDS" | sed "s/\$YEAR/$YEAR/g")

# # Execute SQL commands using SQL*Plus
# echo "$SQL_COMMANDS" | sqlplus -S / as sysdba

# # Check if SQL*Plus command was successful
# if [ $? -eq 0 ]; then
#     echo "Directory reset for year $YEAR completed successfully."
# else
#     echo "Error: Failed to execute SQL commands for year $YEAR."
#     exit 1
# fi

# exit 0