#!/bin/bash

# Run RMAN full backup
rman target / <<EOF

RUN {
  # Backup full database
  BACKUP AS BACKUPSET
    TAG='FULL_DB_BACKUP'
    FORMAT '/project/orabackup/db_%T_%U.bkp'
    DATABASE;

  # Backup archived logs
  BACKUP AS BACKUPSET
    TAG='ARCHIVELOG_BACKUP'
    FORMAT '/project/orabackup/arch_%T_%U.bkp'
    ARCHIVELOG ALL NOT BACKED UP DELETE INPUT;

  # Backup current control file
  BACKUP AS BACKUPSET
    TAG='CONTROLFILE_BACKUP'
    FORMAT '/project/orabackup/ctl_%T_%U.bkp'
    CURRENT CONTROLFILE;
}

# Optional: show summary
LIST BACKUP SUMMARY;

EOF
