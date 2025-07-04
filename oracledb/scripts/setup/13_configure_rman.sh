#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     configure_rman_backup.sh
# Description:     Configures RMAN persistent settings for Oracle database
#                  backups, including control file backup, retention policy,
#                  backup size limits, and compression.
# Usage:           ./configure_rman_backup.sh
# Requirements:    Oracle RMAN must be available in the environment.
# -----------------------------------------------------------------------------

# Set the backup path using fra
BACKUP_PATH="/opt/oracle/fast_recovery_area"

# Check if the backup directory exists
if [ ! -d "$BACKUP_PATH" ]; then
    echo "########################################################"
    echo "ERROR: Backup directory does not exist at $BACKUP_PATH  "
    echo "########################################################" >&2

else

    echo "########################################################"
    echo "Starting RMAN configuration...                          "
    echo "########################################################"

    # Run RMAN commands to configure persistent settings
    rman target / <<EOF

# Enable control file autobackup
CONFIGURE CONTROLFILE AUTOBACKUP ON;

# Set control file backup location: FRA
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO 'controlfile_%F.bkp';

# Keep 7 days of backup history
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

# Limit the size of backup sets
CONFIGURE MAXSETSIZE TO 10 G;

# Set default device type to DISK
CONFIGURE DEFAULT DEVICE TYPE TO DISK;

# Enable parallelism for faster backups
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO BACKUPSET;

# Compress backups to save space
CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT';

# Backup optimization
CONFIGURE BACKUP OPTIMIZATION ON;

# Archive log deletion policy
CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 1 TIMES TO DISK;

# Show current RMAN configuration
SHOW ALL;

EOF

    echo "########################################################"
    echo "RMAN configuration completed successfully.              "
    echo "########################################################"

fi
