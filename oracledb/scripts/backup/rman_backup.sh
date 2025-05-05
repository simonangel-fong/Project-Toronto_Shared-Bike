#!/bin/bash

# # Directory Existence Check
# if [ ! -d "/project/orabackup" ]; then
#   echo "Backup directory does not exist." >&2
#   exit 1
# fi

# Run RMAN full backup
rman target / <<EOF

RUN {

  # clean up metadata and expired files
  CROSSCHECK BACKUP;
  DELETE NOPROMPT EXPIRED BACKUP;

  CROSSCHECK ARCHIVELOG ALL;
  DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;

  ALLOCATE CHANNEL ch1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL ch2 DEVICE TYPE DISK;

  BACKUP AS BACKUPSET DATABASE
    FORMAT '/project/orabackup/db_%U.bkp'
    INCLUDE CURRENT CONTROLFILE
    TAG 'FULL_DB_BACKUP';

  BACKUP ARCHIVELOG ALL
    FORMAT '/project/orabackup/arch_%U.bkp'
    DELETE INPUT
    TAG 'ARCHIVELOG_BACKUP';

  RELEASE CHANNEL ch1;
  RELEASE CHANNEL ch2;
}

# Show backup summary
LIST BACKUP SUMMARY;

EOF
