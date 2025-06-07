# Toronto Shared Bike Data Analysis: Data Warehouse - ELT Design

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Data Warehouse - ELT Design](#toronto-shared-bike-data-analysis-data-warehouse---elt-design)
  - [Data Processing Strategy](#data-processing-strategy)
    - [Key Column](#key-column)
    - [Non-Key Column](#non-key-column)
    - [Source File](#source-file)
  - [External Table: Extract](#external-table-extract)
    - [External Table](#external-table)
    - [Staging table](#staging-table)
  - [Staging Table: Transfom](#staging-table-transfom)
  - [Load (L)](#load-l)

---

## Data Processing Strategy

- Goal

  - Capture as many meaningful records as possible

- Assumption:

  - `trip_id` is unique in the datasets.
  - `start_time`, `end_time` can be transform into date type.
  - `start_station_id`, `end_station_id` are the key to identify the station.

### Key Column

| Column             | Null/'Null' | Invalid Format | Invalid Value |
| ------------------ | ----------- | -------------- | ------------- |
| `trip_id`          | Delete      | Delete         |               |
| `trip_duration`    | Delete      | Delete         | Delete (`<0`) |
| `start_time`       | Delete      | Delete         |               |
| `start_station_id` | Delete      | Delete         |               |
| `end_station_id`   | Delete      | Delete         |               |

---

### Non-Key Column

| Column               | Null/'Null'                        | Invalid Format                     | Invalid Value |
| -------------------- | ---------------------------------- | ---------------------------------- | ------------- |
| `start_station_name` | Replace(`'UNKNOWN'`)               |                                    |               |
| `end_station_name`   | Replace(`'UNKNOWN'`)               |                                    |               |
| `end_time`           | Calculate(`start_time`+`duration`) | Calculate(`start_time`+`duration`) |               |
| `user_type`          | Replace(`'UNKNOWN'`)               |                                    |               |
| `bike_id`            | Replace(`'-1`)                     |                                    |               |
| `model`              | Replace(`'UNKNOWN'`)               |                                    |               |

---

### Source File

- Central Source Data Repository:
  - `/project/data/`
  - Structure:
    - `/project/data/`: directory for the data of year YYYY
  - File Naming:
    - `Ridership-YYYY-Q1*.csv`: Quarterly CSV files
    - `Ridership-YYYY-01*.csv`: Monthly CSV files
- Oracle Directory:
  - Directory Name: `data_dir`
  - Procedure: `SYS.UPDATE_DIRECTORY_FOR_YEAR()`
- Miscellaneous
  - Permission for database user
  - Ownership:`oracle:oinstall`
  - Permission: `750`

---

## External Table: Extract

- Strategy:

  - 1. Capture as many record as possible, by large length size varchar2
  - 2. No validation
  - 3. enable log file and bad file to capture error

---

### External Table

- External Table: `ext_trip`

| Column Name          | Data Type     | Description              |
| -------------------- | ------------- | ------------------------ |
| `trip_id`            | VARCHAR2(15)  | Trip ID                  |
| `trip_duration`      | VARCHAR2(15)  | Trip duration in seconds |
| `start_time`         | VARCHAR2(50)  | Trip start timestamp     |
| `start_station_id`   | VARCHAR2(15)  | Start station reference  |
| `start_station_name` | VARCHAR2(100) | Start station name       |
| `end_time`           | VARCHAR2(50)  | Raw trip end timestamp   |
| `end_station_id`     | VARCHAR2(15)  | End station reference    |
| `end_station_name`   | VARCHAR2(100) | End station name         |
| `bike_id`            | VARCHAR2(15)  | Bike identifier          |
| `user_type`          | VARCHAR2(50)  | User classification      |
| `model`              | VARCHAR2(50)  | Bike model               |

- Enable PARALLEL: faster CSV reads

---

### Staging table

- Table space: `STAGING_TBSP`:

  - Tablespace for staging table.
  - Block size: default

- Staging table: `staging_trip`
  - same strucutre as the external table to capture as many record as possible

| Column Name          | Data Type     | Description              |
| -------------------- | ------------- | ------------------------ |
| `trip_id`            | VARCHAR2(15)  | Trip ID                  |
| `trip_duration`      | VARCHAR2(15)  | Trip duration in seconds |
| `start_time`         | VARCHAR2(50)  | Trip start timestamp     |
| `start_station_id`   | VARCHAR2(15)  | Start station reference  |
| `start_station_name` | VARCHAR2(100) | Start station name       |
| `end_time`           | VARCHAR2(50)  | Raw trip end timestamp   |
| `end_station_id`     | VARCHAR2(15)  | End station reference    |
| `end_station_name`   | VARCHAR2(100) | End station name         |
| `bike_id`            | VARCHAR2(15)  | Bike identifier          |
| `user_type`          | VARCHAR2(50)  | User classification      |
| `model`              | VARCHAR2(50)  | Bike model               |

- Table space: `STAGING_TBSP`

---

## Staging Table: Transfom

- Rules on Key columns

| Rule Name                 | Stage     | Target Column | Condition         | Action |
| ------------------------- | --------- | ------------- | ----------------- | ------ |
| `REMOVE_NULL_KEYCOL`      | Transform | Key Columns   | Null values       | Remove |
| `REMOVE_VALID_TYPE`       | Transform | Key Columns   | invalid data type | Remove |
| `REMOVE_INVALID_DURATION` | Transform | `duration`    | 0, <0             | Remove |

| Rule Name         | Stage     | Target Column                           | Condition                | Action                           |
| ----------------- | --------- | --------------------------------------- | ------------------------ | -------------------------------- |
| `SUB_ENDTIME`     | Transform | `end_time`                              | Null values/Invalid Type | Substitute: start_time + duratio |
| `SUB_STATIONNAME` | Transform | `start_station_name`,`end_station_name` | Null values              | Substitute: UNKNOWN              |
| `SUB_USERTYPE`    | Transform | `user_type`                             | Null values              | Substitute:UNKNOWN               |
| `SUB_BIKEID`      | Transform | `bike_id`                               | Null values              | Substitute: -1 (unknown)         |
| `SUB_BIKEMODEL`   | Transform | `model`                                 | Null values              | Substitute: UNKNOWN              |

---

## Load (L)

- Rule

| Rule Name          | Stage | Target Column              | Condition    | Action                 |
| ------------------ | ----- | -------------------------- | ------------ | ---------------------- |
| `NORM_STATIONNAME` | Load  | `dim_station.station_name` | Inconsistent | Substitute: the latest |

- Using Merge statement
  - `dim_time`: Generate columns based on the `stag_trip.start_time`.
    - Match:
      - `stag_trip.start_time` = `dim_time.dim_time_timestamp`
      - UNION `stag_trip.end_time` = `dim_time.dim_time_timestamp`
    - If matched, no action.
    - If not mateched, insert new time record:
      - `dim_time_timestamp`: date type `stag_trip.start_time`
      - `dim_time_id`: `YYYYMMDDHHMI`
      - `dim_time_year`: `YYYY`
      - `dim_time_quarter`: `QQ`
      - `dim_time_month`: `MM`
      - `dim_time_day`: `DD`
      - `dim_time_week`: `WK`
      - `dim_time_weekday`: `WEEKDAY`
      - `dim_time_hour`: `HH`
      - `dim_time_minute`: `MI`
  - `dim_station`: Normalize station_name, updating the latest station name.
    - Match:
      - `stag_trip.start_station_id` = `dim_station.dim_station_id`
      - OR `stag_trip.end_station_id` = `dim_station.dim_station_id`
      - If matched, update:
        - `dim_station_name`: update the latest station name
      - If not matched, insert new station record
  - `dim_bike`:
    - Match: `stag_trip.bike_id` = `dim_bike.dim_bike_id`
      - If matched:
        - `dim_bike.dim_bike_model` : update the latest model name
      - If not matched, insert new bike record
  - `dim_user_type`:
    - Match: `stag_trip.user_type` = `dim_user_type.dim_user_type_name`
      - If matched,:no action
      - If not mateched:
        - insert new user type record.
  - `fact_trip`: Import or update trip record.
    - Match: `stag_trip.trip_id` = `fact_trip.fact_trip_source_id`
      - If matched:
        - update the measure
      - If no mateched
        - insert new fact record.
