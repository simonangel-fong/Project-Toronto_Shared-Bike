# Toronto Shared Bike Data Analysis: Backup Plan (Development)

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Backup Plan (Development)](#toronto-shared-bike-data-analysis-backup-plan-development)
  - [Backup Plan](#backup-plan)
  - [Commands](#commands)

---

## Backup Plan

| **Backup Concern**         | **Value**            | **Description**                                                                 |
| -------------------------- | -------------------- | ------------------------------------------------------------------------------- |
| Control file autobackup    | ON                   | Ensures the control file is backed up automatically after structural changes.   |
| Control file backup path   | `/project/orabackup` | Sets the path and filename pattern for control file backups.                    |
| Control file backup format | `controlfile_%F.bkp` | Sets the path and filename pattern for control file backups.                    |
| Retention policy           | 7 days               | Keeps backups required to recover the database to any point in the last 7 days. |
| Max backup set size        | 8G                   | Limits the size of any single backup set (optional).                            |
| Default device type        | DISK                 | Specifies that all backups should go to disk by default.                        |
| Disk parallelism           | 2                    | Enables two parallel backup streams to speed up disk backups.                   |
| Backup type                | BACKUPSET            | Chooses `BACKUPSET` as the format for backups.                                  |
| Compression algorithm      | BASIC                | Applies basic compression to reduce backup size (may require license).          |
| Compression mode           | DEFAULT              | Uses the default compression behavior for the specified Oracle version.         |
| Backup optimization        | ON                   | Skips backing up files that haven't changed since the last backup.              |
| Show configuration         | `SHOW ALL`           | Displays current RMAN configuration settings.                                   |

---

## Commands

```sh
# build up container
docker compose -f compose.oracledb.dev.yaml up --build -d

# configure RMAN
docker exec -it oracle19cDB bash /project/scripts/backup/rman_configure.sh

# backup RMAN
docker exec -it oracle19cDB bash /project/scripts/backup/rman_backup.sh

# restore and recover
docker exec -it oracle19cDB bash /project/scripts/backup/rman_recovery.sh

# cutom command
docker exec -it oracle19cDB rman target /
```
