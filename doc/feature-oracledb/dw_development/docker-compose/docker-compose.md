# Toronto Shared Bike Data Analysis: Data Development - Docker Compose Oracle Database 19c

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Data Development - Docker Compose Oracle Database 19c](#toronto-shared-bike-data-analysis-data-development---docker-compose-oracle-database-19c)
  - [Docker Compose Configuration](#docker-compose-configuration)
    - [Oracle DB Service](#oracle-db-service)
    - [Evironment Variables](#evironment-variables)
    - [Volumes](#volumes)
    - [Networks](#networks)
    - [Healthcheck](#healthcheck)
    - [Resource Limits](#resource-limits)
  - [Commnad to build](#commnad-to-build)
  - [Execute ETL](#execute-etl)

---

## Docker Compose Configuration

- **Project Name**:

  - `toronto-shared-bike`

- **File**:

  - `compose.oracledb.dev.yaml`

- **Purpose**:

  - Sets up an Oracle 19c database container for development use in the Toronto Shared Bike project.

---

### Oracle DB Service

| Element        | Value                                     | Description                                      |
| -------------- | ----------------------------------------- | ------------------------------------------------ |
| Service        | `oracle19cDB-dev`                         | Oracle 19c service for development               |
| Container Name | `oracle19cDB-dev`                         | Name of the running container                    |
| Image          | `simonangelfong/oracledb19c:1.0`          | Custom Oracle 19c image                          |
| Restart Policy | `unless-stopped`                          | Keeps container running unless stopped manually  |
| Secrets        | `./oracle19cDB/oracle19cDB_sys_token.txt` | SYS password stored securely                     |
| Network        | `public-net`, `private-net`               | Connected to both external and internal networks |

---

### Evironment Variables

| Element                    | Value                       | Description                        |
| -------------------------- | --------------------------- | ---------------------------------- |
| Environment Variables File | `./env/dev.env`             | Contains values like `ORACLE_SID`  |
| `ORACLE_PWD`               | `/run/secrets/orcl_sys_pwd` | Path to SYS password (from secret) |

---

### Volumes

| Volumes               | Value                         | Description             |
| --------------------- | ----------------------------- | ----------------------- |
| `./setup`             | `/opt/oracle/scripts/setup`   | Initialization scripts  |
| `./startup`           | `/opt/oracle/scripts/startup` | Startup logic/scripts   |
| `../data`             | `/tmp`                        | Source data (e.g. CSVs) |
| `oracledata (volume)` | `/opt/oracle/oradata`         | Oracle data persistence |

---

### Networks

| Network       | Description                |
| ------------- | -------------------------- |
| `public-net`  | Default external bridge    |
| `private-net` | Internal, isolated network |

---

### Healthcheck

| Element      | Value | Description                                |
| ------------ | ----- | ------------------------------------------ |
| Interval     | `30s` | Time between health checks                 |
| Timeout      | `10s` | Timeout for a single health check          |
| Retries      | `5`   | Number of retries before marking as failed |
| Start Period | `5m`  | Wait time before the first check           |

---

### Resource Limits

| Resource | Value                      | Description                  |
| -------- | -------------------------- | ---------------------------- |
| CPUs     | `2.0`                      | Max CPU usage                |
| Memory   | `8g` max,<br>`4g` reserved | RAM allocation & reservation |

---

## Commnad to build

```sh
# build
docker compose -f compose.oracledb.dev.yaml up --build -d
docker compose -f compose.oracledb.dev.yaml down
```

---

## Execute ETL

```sh
# set script permission
docker exec -it -u root:root oracle19cDB-dev bash /project/scripts/01set_permission.sh

# execute ETL batch job
docker exec -it oracle19cDB-dev bash /project/scripts/etl/sh02_etl_job.sh

# execute MV refresh job
docker exec -it oracle19cDB-dev bash /project/scripts/mv/sh01_refresh.sh
```