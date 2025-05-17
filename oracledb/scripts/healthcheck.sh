#!/bin/bash

# RETVAL=`sqlplus -silent / as sysdba <<EOF
# SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
# SELECT 'Alive' FROM dual;
# EXIT;
# EOF`

RETVAL=$(
  sqlplus -silent / as sysdba <<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT open_mode FROM v\\$pdbs WHERE name = 'TORONTO_SHARED_BIKE';
EXIT;
EOF
)

if [ "\${RETVAL}" = "READ WRITE" ]; then
  echo "Toronto_shared_bike pdb is opened."
  exit 0
else
  echo "Toronto_shared_bike pdb is not opened."
  exit 1
fi
