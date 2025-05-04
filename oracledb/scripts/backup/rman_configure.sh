#!/bin/bash

# Run RMAN commands to configure persistent settings
rman target / <<EOF

# Enable control file autobackup (ensures recoverability even if control file is lost)
CONFIGURE CONTROLFILE AUTOBACKUP ON;

# Set control file backup location
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/project/orabackup/controlfile_%F.bkp';

# Keep 7 days of backup history
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

# Limit the size of backup sets (optional)
CONFIGURE MAXSETSIZE TO 8 G;

# Set default device type to DISK
CONFIGURE DEFAULT DEVICE TYPE TO DISK;

# Enable parallelism for faster backups (optional, tune based on your CPU)
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO BACKUPSET;

# Compress backups to save space (optional, requires license in some editions)
CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT';
CONFIGURE BACKUP OPTIMIZATION ON;

# Show current RMAN configuration
SHOW ALL;

EOF
