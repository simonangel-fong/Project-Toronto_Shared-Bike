#!/bin/bash

# Create date-based subdirectory for backups
BACKUP_DIR="/project/orabackup/$(date +%Y%m%d)"

mkdir -pv "$BACKUP_DIR"

# Run RMAN full backup
rman target / <<EOF

RUN {
  # Backup full database
  BACKUP AS BACKUPSET
    TAG='FULL_DB_BACKUP'
    FORMAT '$BACKUP_DIR/db_%T_%U.bkp'
    DATABASE;

  # Backup archived logs
  BACKUP AS BACKUPSET
    TAG='ARCHIVELOG_BACKUP'
    FORMAT '$BACKUP_DIR/arch_%T_%U.bkp'
    ARCHIVELOG ALL NOT BACKED UP DELETE INPUT;

  # Backup current control file
  BACKUP AS BACKUPSET
    TAG='CONTROLFILE_BACKUP'
    FORMAT '$BACKUP_DIR/ctl_%T_%U.bkp'
    CURRENT CONTROLFILE;
}

# Optional: show summary
LIST BACKUP SUMMARY;

EOF
