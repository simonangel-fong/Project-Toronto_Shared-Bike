#!/bin/bash

# Script: sh02_etl_job.sh
# Purpose: Execute SQL to execute ELT job.
# Usage: ./sh02_etl_job.sh

sqlplus / as sysdba<<EOF
@/project/scripts/etl/sql01_extract.sql
@/project/scripts/etl/sql02_transform.sql
@/project/scripts/etl/sql03_load.sql
@/project/scripts/etl/sql04_confirm.sql
exit
EOF
