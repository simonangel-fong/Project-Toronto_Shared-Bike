# Toronto Shared Bike Data Analysis: Data Development - Backup Plan

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Data Development - Backup Plan](#toronto-shared-bike-data-analysis-data-development---backup-plan)
  - [Backup](#backup)
    - [Enable ARCHIVELOG](#enable-archivelog)
    - [RMAN](#rman)

---

## Backup

### Enable ARCHIVELOG

- DB level

```sql
SHUTDOWN IMMEDIATE;

-- Start CDB in MOUNT mode
STARTUP MOUNT;

-- Enable ARCHIVELOG mode
ALTER DATABASE ARCHIVELOG;

-- Open the CDB
ALTER DATABASE OPEN;

-- Verify ARCHIVELOG mode is enabled
ARCHIVE LOG LIST;
```

---

### RMAN

- Script

```sh
docker compose -f compose.oracledb.dev.yaml up --build -d

docker exec -it oracle19cDB bash /project/scripts/backup/rman_configure.sh
docker exec -it oracle19cDB bash /project/scripts/backup/rman_backup.sh
docker exec -it oracle19cDB bash /project/scripts/backup/rman_recovery.sh

docker exec -it oracle19cDB rman target /
```