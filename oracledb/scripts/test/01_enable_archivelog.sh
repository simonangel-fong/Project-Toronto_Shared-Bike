#!/bin/bash

set -e  # Exit on any error

# Get log mode
ARCHIVELOG_MODE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT log_mode FROM v\$database;
EXIT
EOF
)

# Trim whitespace
ARCHIVELOG_MODE=$(echo "$ARCHIVELOG_MODE" | xargs)

echo $ARCHIVELOG_MODE

# Check the result
if [ "$ARCHIVELOG_MODE" != "ARCHIVELOG" ]; then
  echo "❌ ARCHIVELOG mode is NOT enabled. Aborting script."
  exit 1
else
  echo "✅ ARCHIVELOG mode is enabled. Continuing..."
  exit 0
fi

