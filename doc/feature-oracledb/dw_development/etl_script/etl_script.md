# Toronto Shared Bike Data Analysis: ETL Job (Development)

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: ETL Job (Development)](#toronto-shared-bike-data-analysis-etl-job-development)
  - [ETL Job](#etl-job)
  - [Commands](#commands)

---

## ETL Job

| Predefined Script           | Description                                   |
| --------------------------- | --------------------------------------------- |
| `single_year_etl_job.sql`   | Executes an ELT pipeline for a specified year |
| `multiple_year_etl_job.sql` | Runs ELT jobs for a range of years            |

---

## Commands

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
