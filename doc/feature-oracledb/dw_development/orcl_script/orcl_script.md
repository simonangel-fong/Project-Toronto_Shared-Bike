# Toronto Shared Bike Data Analysis: Data Development - Setup Scripts

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Data Development - Setup Scripts](#toronto-shared-bike-data-analysis-data-development---setup-scripts)
  - [SQL Script Catalog](#sql-script-catalog)
    - [01block\_size](#01block_size)
    - [02PDB\_Creation](#02pdb_creation)
    - [03TBSP\_Creation](#03tbsp_creation)
    - [04Schema\_Creation](#04schema_creation)
    - [05DW\_Creation](#05dw_creation)
    - [06ELT\_Creation](#06elt_creation)
    - [07MV\_Creation](#07mv_creation)
    - [08User\_Creation](#08user_creation)
    - [09ELT\_Extract](#09elt_extract)

---

## SQL Script Catalog

| Script Name             | Description                                                                |
| ----------------------- | -------------------------------------------------------------------------- |
| `01block_size.sql`      | Enable 32K block size for fact table tablespace (requires SPFILE restart). |
| `02PDB_Creation.sql`    | Create a pluggable database (PDB) for the project.                         |
| `03TBSP_Creation.sql`   | Create tablespaces including a 32K tablespace for fact tables.             |
| `04Schema_Creation.sql` | Create application schemas and grant necessary privileges.                 |
| `05DW_Creation.sql`     | Create dimension and fact tables for the data warehouse (star schema).     |
| `06ELT_Creation.sql`    | Create staging tables and control tables for ELT process.                  |
| `07MV_Creation.sql`     | Create materialized views for aggregated and pre-computed data.            |
| `08User_Creation.sql`   | Create users (e.g., developer, analyst) and assign roles.                  |
| `09ELT_Extract.sql`     | Extract data from OLTP source into staging tables.                         |
| `10ELT_Transform.sql`   | Transform staging data into dimension and fact format.                     |
| `11ELT_Load.sql`        | Load transformed data into the data warehouse schema.                      |
| `12MV_Refresh.sql`      | Refresh materialized views to reflect latest data changes.                 |

---

### 01block_size

| Configuration       | Value  | Description                                      |
| ------------------- | ------ | ------------------------------------------------ |
| `DB_32K_CACHE_SIZE` | 256M   | Memory allocated for the 32K block buffer cache. |
| `SCOPE`             | SPFILE | Requires DB restart to take effect (persistent). |

---

### 02PDB_Creation

| Configuration      | Value                                                         | Description                                             |
| ------------------ | ------------------------------------------------------------- | ------------------------------------------------------- |
| Container          | `CDB$ROOT`                                                    | The PDB is created from the root container.             |
| PDB Name           | `toronto_shared_bike`                                         | Name of the pluggable database for the data warehouse.  |
| Admin User         | `pdb_adm`                                                     | Admin user created during PDB setup.                    |
| Admin Password     | `PDBSecurePassword123`                                        | Password for the admin user.                            |
| Admin Role         | `DBA`                                                         | Grants full administrative privileges to the PDB admin. |
| Default Tablespace | `users`                                                       | Default tablespace for the PDB.                         |
| Datafile Location  | `/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/users01.dbf` | Location and size config of the datafile.               |
| File Name Convert  | from: `pdbseed`<br>to: `toronto_shared_bike`                  | Maps seed files to new PDB files.                       |
| Open on Startup    | `SAVE STATE`                                                  | Ensures the PDB auto-opens when the CDB starts.         |

---

### 03TBSP_Creation

- Session:`toronto_shared_bike`

- `FACT_TBSP`

| Configuration            | Value                                | Description                         |
| ------------------------ | ------------------------------------ | ----------------------------------- |
| Datafiles                | `fact_tbsp01.dbf`, `fact_tbsp02.dbf` | Two 100MB files with 1GB autoextend |
| Block Size               | 32K                                  | Optimized for large fact table rows |
| Max Size per Datafile    | 50G                                  | Upper storage limit per file        |
| Extent Management        | LOCAL AUTOALLOCATE                   | Automatic extent sizing             |
| Segment Space Management | AUTO                                 | Automatically manages free space    |
| Logging                  | Enabled                              | Redo logging is turned on           |
| Online Status            | ONLINE                               | Available for use immediately       |

- `DIM_TBSP`

| Configuration            | Value                              | Description                         |
| ------------------------ | ---------------------------------- | ----------------------------------- |
| Datafiles                | `dim_tbsp01.dbf`, `dim_tbsp02.dbf` | Two 50MB files with 25MB autoextend |
| Block Size               | 8K                                 | Default block size                  |
| Max Size per Datafile    | 5G                                 | Upper storage limit per file        |
| Extent Management        | LOCAL AUTOALLOCATE                 | Automatic extent sizing             |
| Segment Space Management | AUTO                               | Automatically manages free space    |
| Logging                  | Enabled                            | Redo logging is turned on           |
| Online Status            | ONLINE                             | Available for use immediately       |

- `INDEX_TBSP`

| Configuration            | Value                                  | Description                         |
| ------------------------ | -------------------------------------- | ----------------------------------- |
| Datafiles                | `index_tbsp01.dbf`, `index_tbsp02.dbf` | Two 50MB files with 25MB autoextend |
| Block Size               | 8K                                     | Default block size                  |
| Max Size per Datafile    | 5G                                     | Upper storage limit per file        |
| Extent Management        | LOCAL AUTOALLOCATE                     | Automatic extent sizing             |
| Segment Space Management | AUTO                                   | Automatically manages free space    |
| Logging                  | Enabled                                | Redo logging is turned on           |
| Online Status            | ONLINE                                 | Available for use immediately       |

- `STAGING_TBSP`

| Configuration            | Value                        | Description                         |
| ------------------------ | ---------------------------- | ----------------------------------- |
| Datafiles                | `stage01.dbf`, `stage02.dbf` | Two 1GB files with 500MB autoextend |
| Block Size               | 8K                           | Default block size                  |
| Max Size per Datafile    | 10G                          | Upper storage limit per file        |
| Extent Management        | LOCAL AUTOALLOCATE           | Automatic extent sizing             |
| Segment Space Management | AUTO                         | Automatically manages free space    |
| Logging                  | Enabled                      | Redo logging is turned on           |
| Online Status            | ONLINE                       | Available for use immediately       |

- `MV_TBSP`

| Configuration            | Value                            | Description                          |
| ------------------------ | -------------------------------- | ------------------------------------ |
| Datafiles                | `MV_TBSP01.dbf`, `MV_TBSP02.dbf` | Two 100MB files with 50MB autoextend |
| Max Size per Datafile    | 2G                               | Upper storage limit per file         |
| Extent Management        | LOCAL                            | Manual extent sizing allowed         |
| Segment Space Management | AUTO                             | Automatically manages free space     |

---

### 04Schema_Creation

- Session: `toronto_shared_bike`

| Configuration        | Value                     | Description                                                             |
| -------------------- | ------------------------- | ----------------------------------------------------------------------- |
| User Name            | `DW_SCHEMA`               | Dedicated schema for the Data Warehouse                                 |
| Authentication       | Password                  | Password-protected user:                                                |
| Default Tablespace   | `FACT_TBSP`               | Fact data is stored here by default                                     |
| Temporary Tablespace | `TEMP`                    | Used for sort and temporary operations                                  |
| Tablespace Quotas    | UNLIMITED on all \*\_TBSP | Full access to all warehouse tablespaces (`FACT`, `DIM`, `INDEX`, etc.) |
| Privileges Granted   | `CREATE TABLE`            | Allows creation of tables inside the schema                             |

---

### 05DW_Creation

- Session: `toronto_shared_bike`

- `dim_time`

| Configuration | Value         | Description                              |
| ------------- | ------------- | ---------------------------------------- |
| Tablespace    | DIM_TBSP      | Data stored in DIM_TBSP                  |
| Primary Key   | `dim_time_id` | Unique identifier for each time entry    |
| Indexes       | 2             | On `dim_time_timestamp`, `(year, month)` |
| Constraints   | 7             | Includes checks on date parts            |

- Granularity: Minute-level (YYYYMMDDHHMI)

- `dim_station`

| Configuration | Value            | Description             |
| ------------- | ---------------- | ----------------------- |
| Tablespace    | DIM_TBSP         | Data stored in DIM_TBSP |
| Primary Key   | `dim_station_id` | Unique station ID       |
| Indexes       | 1                | On `dim_station_name`   |

- Notes: Name field limited to 100 characters

- `dim_bike`

| Configuration | Value         | Description             |
| ------------- | ------------- | ----------------------- |
| Tablespace    | DIM_TBSP      | Data stored in DIM_TBSP |
| Primary Key   | `dim_bike_id` | Unique bike ID          |
| Indexes       | 0             | Only PK index is used   |

- `dim_user_type`

| Configuration | Value               | Description                               |
| ------------- | ------------------- | ----------------------------------------- |
| Tablespace    | DIM_TBSP            | Data stored in DIM_TBSP                   |
| Primary Key   | `dim_user_type_id`  | Auto-incremented identity column          |
| Indexes       | 2                   | PK + Unique index on `dim_user_type_name` |
| Constraints   | 1 Unique Constraint | Enforces no duplicate user type names     |

- `fact_trip`

| Configuration           | Value                       | Description                                                           |
| ----------------------- | --------------------------- | --------------------------------------------------------------------- |
| Tablespace              | FACT_TBSP                   | Main data stored in FACT_TBSP                                         |
| Compression             | ROW STORE COMPRESS ADVANCED | Advanced row compression enabled                                      |
| Primary Key             | `fact_trip_id`              | Surrogate key with auto-increment                                     |
| Foreign Keys            | 6                           | References all dimension tables                                       |
| Partitioning            | Range + Subpartitioning     | Yearly partitions with monthly subpartitions based on `start_time_id` |
| Subpartitions           | 12 per year                 | One per month from Jan to Dec                                         |
| Partition Years Covered | 2019 - 2022                 | Add more partitions as needed for future data                         |

---

### 06ELT_Creation

- Session: `toronto_shared_bike`

- External Table: `external_ridership`

| Configuration   | Value            | Description                                          |
| --------------- | ---------------- | ---------------------------------------------------- |
| Schema          | `DW_SCHEMA`      | Where the external table is defined                  |
| Directory       | `data_dir`       | Logical path to `/tmp/2019`, holding CSV files       |
| File Pattern    | `Ridership*.csv` | Supports multiple CSV files                          |
| Loader Type     | ORACLE_LOADER    | External table uses Oracle Loader for CSV parsing    |
| Parallelism     | 5                | Enables parallel access for performance              |
| Reject Limit    | UNLIMITED        | Allows all rows to be processed regardless of errors |
| Fields Skipped  | 1                | Skips header row in each file                        |
| Quoted Fields   | Optional `" "`   | Fields may be optionally enclosed in quotes          |
| Field Separator | `,`              | CSV file delimiter                                   |

- Staging Table: staging_trip

| Configuration | Value        | Description                                            |
| ------------- | ------------ | ------------------------------------------------------ |
| Schema        | `DW_SCHEMA`  | Table created in the same schema as the external table |
| Tablespace    | STAGING_TBSP | Data is stored in the staging tablespace               |
| Logging       | NOLOGGING    | Reduces redo generation for performance                |
| PCTFREE       | 0            | No free space reserved in each data block              |
| Quota         | UNLIMITED    | `DW_SCHEMA` granted unlimited quota on STAGING_TBSP    |

---

### 07MV_Creation

- Session: `toronto_shared_bike`

- Materialized View Logs

| Table         | Tablespace | Columns Logged                                        | Notes                                     |
| ------------- | ---------- | ----------------------------------------------------- | ----------------------------------------- |
| `fact_trip`   | MV_TBSP    | `start_time_id`, `start_station_id`, `end_station_id` | Uses ROWID, SEQUENCE, includes new values |
| `dim_time`    | MV_TBSP    | All key time parts (`year`, `quarter`, `month`, etc.) | Logged for time-based aggregations        |
| `dim_station` | MV_TBSP    | `station_id`, `station_name`                          | Logged though data is relatively static   |

- Materialized Views `MV_TIME_TRIP`

| Configuration    | Value      | Description                                       |
| ---------------- | ---------- | ------------------------------------------------- |
| Tablespace       | MV_TBSP    | Data stored in MV_TBSP                            |
| Partitioning     | By year    | Year-based range partitions (2019–2025, MAXVALUE) |
| Refresh Strategy | FAST       | ON DEMAND with query rewrite enabled              |
| Indexes          | 2          | On `(year, month)` and `(year, hour)`             |
| Aggregations     | Time-based | Trips grouped by time dimensions                  |

- `MV_STATION_TRIP`

| Configuration    | Value      | Description                               |
| ---------------- | ---------- | ----------------------------------------- |
| Tablespace       | MV_TBSP    |                                           |
| Refresh Strategy | FAST       | ON DEMAND with query rewrite enabled      |
| Grouping         | By station | Trip counts grouped by start/end stations |
| Logic            | Dual count | Start and end station participation       |

- `MV_STATION_ROUTE`

| Configuration    | Value    | Description                                    |
| ---------------- | -------- | ---------------------------------------------- |
| Tablespace       | MV_TBSP  |                                                |
| Refresh Strategy | FAST     | ON DEMAND with query rewrite enabled           |
| Grouping         | By route | Trip counts grouped by start–end station pairs |

- `MV_BIKE_TRIP_DURATION`

| Configuration    | Value          | Description                                   |
| ---------------- | -------------- | --------------------------------------------- |
| Tablespace       | MV_TBSP        |                                               |
| Refresh Strategy | COMPLETE       | ON DEMAND, suitable for less frequent updates |
| Aggregations     | Duration-based | Average trip duration per bike                |

- `MV_USER_SEGMENTATION`

| Configuration    | Value        | Description                                      |
| ---------------- | ------------ | ------------------------------------------------ |
| Tablespace       | MV_TBSP      |                                                  |
| Refresh Strategy | COMPLETE     | ON DEMAND                                        |
| Grouping         | User-Time    | Trips grouped by user type and year              |
| Aggregations     | Segmentation | Trip count and average duration per user segment |

---

### 08User_Creation

- Session: `toronto_shared_bike`

- User and Role Setup

| Configuration | Value                              | Description                                     |
| ------------- | ---------------------------------- | ----------------------------------------------- |
| Role Name     | `apiTesterRole`                    | Custom role for read-only API users             |
| Privileges    | `SELECT` on `MV_USER_SEGMENTATION` | Grants access to key MV for analytics/testing   |
| Schema Access | `DW_SCHEMA`                        | Permission restricted to materialized view only |

- apiTester1

| Configuration  | Value                             | Description                                  |
| -------------- | --------------------------------- | -------------------------------------------- |
| Username       | `apiTester1`                      | Application or test user                     |
| Authentication | Password-based                    | User identified by password `"apiTester123"` |
| Privileges     | `CREATE SESSION`, `apiTesterRole` | Can connect and has read-only MV access      |
| Intended Use   | API Testing                       | Limited-access user for querying public MVs  |

---

### 09ELT_Extract
