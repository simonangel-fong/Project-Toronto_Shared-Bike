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

## Commands

- Build and Start

```sh
# Build and run container in detached mode
# update packages and
docker compose -f compose.oracledb.dev.yaml up --build -d && docker exec -it -u root:root oracle19cDB bash /project/scripts/init/init.sh

# Stop
docker compose -f ./oracledb/compose.oracledb.dev.yaml down
```
