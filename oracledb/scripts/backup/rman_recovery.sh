#!/bin/bash

# # Check if backup directory exists
# if [ ! -d "/project/orabackup" ]; then
#   echo "Backup directory /project/orabackup does not exist." >&2
#   exit 1
# fi


# select DBID from v$database;
rman target / <<EOF

STARTUP FORCE MOUNT;

RUN {
  ALLOCATE CHANNEL ch1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL ch2 DEVICE TYPE DISK;

  # Restore the full database
  RESTORE DATABASE;

  # Recover the database using available archive logs and backups
  RECOVER DATABASE;

  RELEASE CHANNEL ch1;
  RELEASE CHANNEL ch2;
}

# Open the database
ALTER DATABASE OPEN;

EOF