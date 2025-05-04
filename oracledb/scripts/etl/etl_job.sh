#!/bin/bash

# Script: sh02_etl_job.sh
# Purpose: Execute SQL to execute ELT job.
# Usage: ./sh02_etl_job.sh

# define years
YEAR_LIST=(2019 2020)

for year in "${YEAR_LIST[@]}"; do

# update directory
echo "Update directory for year $year."

sqlplus / as sysdba<<EOF
ALTER SESSION set container=toronto_shared_bike;

BEGIN
    update_directory_for_year($year);
END;
/
exit
EOF

# Extract data
echo "Extract data."

sqlplus / as sysdba<<EOF
@/project/scripts/etl/01_extract.sql
exit
EOF

# Transform data
echo "Transform data."

sqlplus / as sysdba<<EOF
@/project/scripts/etl/02_transform.sql
exit
EOF

# Transform data
echo "Transform data."

sqlplus / as sysdba<<EOF
@/project/scripts/etl/03_load.sql
exit
EOF

# Confirm
echo "Confirm."

sqlplus / as sysdba<<EOF
@/project/scripts/etl/04_confirm.sql
exit
EOF

done