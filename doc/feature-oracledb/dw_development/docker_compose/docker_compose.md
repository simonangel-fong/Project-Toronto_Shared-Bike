# Toronto Shared Bike Data Analysis: Docker Compose for Oracle 19c (Development)

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Docker Compose for Oracle 19c (Development)](#toronto-shared-bike-data-analysis-docker-compose-for-oracle-19c-development)
  - [Docker Compose Configuration](#docker-compose-configuration)
    - [Project Overview](#project-overview)
    - [Oracle DB Service](#oracle-db-service)
    - [Environment Variables](#environment-variables)
    - [Volumes](#volumes)
    - [Networks](#networks)
    - [Healthcheck](#healthcheck)
    - [Resource Limits (Optional)](#resource-limits-optional)
    - [Commands](#commands)
  - [ETL Job](#etl-job)
    - [Commands](#commands-1)
  - [Backup Plan](#backup-plan)
  - [Commands](#commands-2)

---

## Docker Compose Configuration

### Project Overview

- Project Name: `toronto-shared-bike`
- Compose File: `compose.oracledb.dev.yaml`
- Prerequisites:
  - Pre-built Image: `simonangelfong/oracledb19c:1.0`
- Purpose:
  - Spin up an Oracle 19c container with custom scripts, data directories, and ETL tools for development.

---

### Oracle DB Service

| Element            | Value                            | Description                                      |
| ------------------ | -------------------------------- | ------------------------------------------------ |
| **Service**        | `oracle19cDB`                    | Oracle 19c service for development               |
| **Container Name** | `oracle19cDB`                    | Name of the running container                    |
| **Image**          | `simonangelfong/oracledb19c:1.0` | Custom Oracle 19c image                          |
| **Restart Policy** | `unless-stopped`                 | Automatically restarts unless manually stopped   |
| **Secrets**        | `./env/orcl_sys_token.txt`       | SYS password stored securely                     |
| **Ports**          | `1521:1521`                      | Oracle listener port exposed                     |
| **Networks**       | `public-net`, `private-net`      | Attached to public (dev) and private (prod) nets |

---

### Environment Variables

| Variable     | Source          | Description                     |
| ------------ | --------------- | ------------------------------- |
| `env_file`   | `./env/dev.env` | External file for env variables |
| `ORACLE_PWD` | From secret     | Oracle SYS password path        |

---

### Volumes

| Host Path                  | Container Path              | Purpose                        |
| -------------------------- | --------------------------- | ------------------------------ |
| `./scripts/setup`          | `/opt/oracle/scripts/setup` | Scripts run at setup           |
| `./scripts`                | `/project/scripts`          | ETL and admin scripts          |
| `../project/data`          | `/project/data`             | CSV and source data            |
| `../project/orabackup`     | `/project/orabackup`        | Local backups                  |
| `oracledata` (Docker vol.) | `/opt/oracle/oradata`       | Oracle persistent data storage |

---

### Networks

| Network       | Type                | Description                   |
| ------------- | ------------------- | ----------------------------- |
| `public-net`  | `bridge`            | Used for dev connectivity     |
| `private-net` | `bridge` (internal) | Isolated for prod-only access |

---

### Healthcheck

| Setting        | Value | Description                          |
| -------------- | ----- | ------------------------------------ |
| `interval`     | `30s` | Time between checks                  |
| `timeout`      | `10s` | Timeout per check                    |
| `retries`      | `5`   | Max retries before unhealthy         |
| `start_period` | `5m`  | Initial delay after container starts |

---

### Resource Limits (Optional)

| Resource | Value                   | Description               |
| -------- | ----------------------- | ------------------------- |
| CPUs     | `2.0`                   | CPU usage limit           |
| Memory   | `8g` max, `4g` reserved | RAM limit and reservation |

---

### Commands

- Build and Start

```sh
# Build and run container in detached mode
# update packages and
docker compose -f compose.oracledb.dev.yaml up --build -d && docker exec -it -u root:root oracle19cDB bash /project/scripts/init/init.sh

# Stop
docker compose -f compose.oracledb.dev.yaml down
```

---

## ETL Job

- ETL Job workflow:
  - 1. Reset Oracle Directory.
  - 2. Extract data from flat file to external table, then import to stagging table.
  - 3. Transform data in the stagging table.
  - 4. Load transformed data from stagging table to Data warehouse.

| Predefined Script           | Description                                   |
| --------------------------- | --------------------------------------------- |
| `single_year_etl_job.sql`   | Executes an ELT pipeline for a specified year |
| `multiple_year_etl_job.sql` | Runs ELT jobs for a range of years            |

### Commands

- ETL Job

```sh
# build up container
docker compose -f compose.oracledb.dev.yaml up --build -d

# ELT for default year (2019)
docker exec -it oracle19cDB bash /project/scripts/etl/single_year_etl_job.sh

# ELT for a given year
docker exec -it oracle19cDB bash /project/scripts/etl/single_year_etl_job.sh 2020

# ELT for a range years
docker exec -it oracle19cDB bash /project/scripts/etl/multiple_year_etl_job.sh 2019 2024
```

- Refresh MV

```sh
# refresh mv
docker exec -it oracle19cDB bash /project/scripts/mv/mv_refresh.sh
```

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

# List all backup
docker exec -it oracle19cDB bash /project/scripts/backup/rman_list_backup.sh

# Create full backup
docker exec -it oracle19cDB bash /project/scripts/backup/rman_create_backup.sh

# create a backup with a given tag name
docker exec -it oracle19cDB bash /project/scripts/backup/rman_create_backup_with_tag.sh INIT_BACKUP   

# restore and recover
docker exec -it oracle19cDB bash /project/scripts/backup/rman_restore_recover.sh

# cutom command
docker exec -it oracle19cDB rman target /
```

---

- Archived: Manually restore and recover

```sh
rman target /
shutdown immediate;
startup nomount

# list all available backup, get the dbid and db name
CATALOG START WITH '/project/orabackup/';
# File Name: /project/orabackup/arch_0g3orc5q_1_1.bkp
  # RMAN-07518: Reason: Foreign database file DBID: 2971528291  Database Name: ORCLCDB

SET DBID = 2971528291;
# executing command: SET DBID
restore controlfile from '/project/orabackup/controlfile_c-2971528291-20250507-02.bkp';
# Starting restore at 08-MAY-25
# using channel ORA_DISK_1

# channel ORA_DISK_1: restoring control file
# channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
# output file name=/opt/oracle/oradata/ORCLCDB/control01.ctl
# Finished restore at 08-MAY-25
ALTER DATABASE MOUNT;
# released channel: ORA_DISK_1
# Statement processed

RESTORE DATABASE;
RECOVER DATABASE NOREDO;
ALTER DATABASE OPEN RESETLOGS;
```
