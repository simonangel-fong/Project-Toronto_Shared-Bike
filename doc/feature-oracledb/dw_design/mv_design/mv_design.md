# Toronto Shared Bike Data Analysis: Data Warehouse - Materialized Design

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Data Warehouse - Materialized Design](#toronto-shared-bike-data-analysis-data-warehouse---materialized-design)
  - [Materialized Design](#materialized-design)
    - [General](#general)
  - [KPI: Trip Trends](#kpi-trip-trends)
    - [KPI: Duration Trends](#kpi-duration-trends)
    - [KPI: Station Usage Trend](#kpi-station-usage-trend)
    - [KPI: User Type Trend](#kpi-user-type-trend)

---

## Materialized Design

### General

- **Storage**:

  - `MV_TBSP`
  - separated tablespace from `FACT_TBSP`, optimizes I/O.

- **Schema**:

  - `dw_schema`

- KPIs in the design require materialized views to improve query performance.

---

## KPI: Trip Trends

- **Goal**:

  - Precompute the total number of trips to analyze temporal usage patterns across the bike-sharing system.

- **View Structure**: `MV_TRIP_TIME`

| Column       | Granularity | Description             |
| ------------ | ----------- | ----------------------- |
| `trip_count` | -           | Total trip volume       |
| `dim_year`   | Year        | Long-term annual trends |
| `dim_month`  | Month       | Monthly usage patterns  |
| `dim_hour`   | Hour        | Hourly peak trends      |

- Source query:

```sql
SELECT
  COUNT(*)            AS  trip_count    -- Measure： Total trip volume
  , t.dim_time_year   AS  dim_year      -- Dimension: Year (e.g., 2025)
  , t.dim_time_month  AS  dim_month     -- Dimension: Month (1-12)
  , t.dim_time_hour   AS  dim_hour      -- Dimension: Hour (0-23)
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
  ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
  t.dim_time_year
  , t.dim_time_month
  , t.dim_time_hour
ORDER BY
  t.dim_time_year
  , t.dim_time_month
  , t.dim_time_hour;

```

- **Refresh Strategy**:

  - `Fast refresh`
  - leverages materialized view logs on `fact_trip` and `dim_time` for incremental updates, ensuring ongoing temporal analysis with minimal overhead.

- **Tablespace**
  - `MV_TBSP`
- **Schema**
  - `dw_schema`
- **Partitioning**
  - `dim_year`
  - for Yearly query optimization.
- **Indexing**
  - Tablespace: `MV_TBSP`
  - Column: (`dim_year`, `dim_month`)
    - Type: Composite B-tree
    - Purpose: Speed up year-month-based queries
  - Column: `(dim_year, dim_hour)`
    - Type: Composite B-tree
    - Purpose: Speeds up hourly duration queries

---

### KPI: Duration Trends

- **Goal**:
  - Precompute the mean trip duration to analyze temporal usage patterns across the bike-sharing system.
- **View Structure**: `MV_DURATION_TIME`

| Column         | Granularity | Description                  |
| -------------- | ----------- | ---------------------------- |
| `duration_avg` | -           | Mean trip duration (seconds) |
| `dim_year`     | Year        | Long-term annual trends      |
| `dim_month`    | Month       | Monthly usage patterns       |
| `dim_hour`     | Hour        | Hourly duration trends       |

- Source Query:

```sql
SELECT
  ROUND(AVG(f.fact_trip_duration),2)  AS  avg_trip_duration   -- Measure：Mean trip duration (seconds)
  , t.dim_time_year                   AS  dim_year            -- Dimension: Year (e.g., 2025)
  , t.dim_time_month                  AS  dim_month           -- Dimension: Month (1-12)
  , t.dim_time_hour                   AS  dim_hour            -- Dimension: Hour (0-23)
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
  ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
  t.dim_time_year
  , t.dim_time_month
  , t.dim_time_hour
ORDER BY
  t.dim_time_year
  , t.dim_time_month
  , t.dim_time_hour;
```

- **Refresh Strategy**:

  - `Complete refresh`
  - mean calculations require full recomputation; refreshed post-load for ongoing temporal analysis.

- **Tablespace**:
  - `MV_TBSP`
- **Schema**:
  - `dw_schema`
- **Partitioning**:
  - `dim_year`
  - optimizes yearly query performance and scalability.
- **Indexing**:
  - Tablespace: `MV_TBSP`
  - Column: `(dim_year, dim_month)`
    - Type: Composite B-tree
    - Purpose: Speeds up year-month-based duration queries
  - Column: `(dim_year, dim_hour)`
    - Type: Composite B-tree
    - Purpose: Speeds up hourly duration queries

---

### KPI: Station Usage Trend

- **Goal**:

  - Precompute trip counts per station to identify the most and least busy stations in the bike-sharing system.

- **View Structure**: `MV_TRIP_STATION`

| Column       | Description                |
| ------------ | -------------------------- |
| trip_count   | Trips starting at station  |
| dim_year     | Annual trends              |
| station_id   | Unique station identifier  |
| station_name | Station name for reporting |

- **Source Query**:

```sql
SELECT
  COUNT(*)              AS  trip_count_by_start   -- Measure: Trips count
  , s.dim_station_id    AS  station_id            -- Dimension: station id
  , s.dim_station_name  AS  station_name          -- Dimension: station name
  , t.dim_time_year     AS  dim_year              -- Dimension: Year (e.g., 2025)
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_station s
  ON f.fact_trip_start_station_id = s.dim_station_id
JOIN dw_schema.dim_time t
  ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
  s.dim_station_id
  , s.dim_station_name
  , t.dim_time_year
ORDER BY
  t.dim_time_year ASC
  , COUNT(*) DESC
  , s.dim_station_name;
```

- **Refresh Strategy**:
  - `Fast refresh`
  - leverages materialized view logs on `fact_trip` and `dim_station` for incremental updates, supporting ongoing station usage analysis.
- **Tablespace**:
  - `MV_TBSP`
- **Schema**:
  - `dw_schema`
- **Partitioning**:
  - None
- **Indexing**:
  - None

---

<!--
### KPI: Route Popularity

- **Goal**:
  - Precompute trip counts between station pairs to identify the popular routes in the bike-sharing system.
- **View Structure**: `MV_ROUTE`

| Column               | Description                 |
| -------------------- | --------------------------- |
| `start_station_id`   | Starting station identifier |
| `start_station_name` | Starting station name       |
| `end_station_id`     | Ending station identifier   |
| `end_station_name`   | Ending station name         |
| `trip_count`         | Number of trips on route    |

- **Source Query**:

```sql
SELECT
    s_start.dim_station_id AS start_station_id,         -- Starting station identifier
    s_start.dim_station_name AS start_station_name,     -- Starting station name
    s_end.dim_station_id AS end_station_id,             -- Ending station identifier
    s_end.dim_station_name AS end_station_name,         -- Ending station name
    COUNT(*) AS trip_count                              -- Number of trips on route
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_station s_start
    ON f.fact_trip_start_station_id = s_start.dim_station_id
JOIN dw_schema.dim_station s_end
    ON f.fact_trip_end_station_id = s_end.dim_station_id
GROUP BY
    s_start.dim_station_id,
    s_start.dim_station_name,
    s_end.dim_station_id,
    s_end.dim_station_name;
```

- **Refresh Strategy**:
  - `Fast refresh`
  - leverages materialized view logs on `fact_trip` and `dim_station` for incremental updates, supporting ongoing route popularity analysis.
- **Tablespace**:
  - `MV_TBSP`
- **Schema**:
  - `dw_schema`
- **Partitioning**:
  - None
- **Indexing**:
  - None

---

### KPI: Bike Utilization Rate

- **Goal**:

  - Precompute total trips and mean duration per bike to evaluate utilization rates in the bike-sharing system.

- **View Structure**: `MV_BIKE_TRIP_DURATION`

| Column              | Description                  |
| ------------------- | ---------------------------- |
| `bike_id`           | Unique bike identifier       |
| `trip_count`        | Total trips per bike         |
| `avg_trip_duration` | Mean trip duration (seconds) |

- **Source Query**:

```sql
SELECT
    b.dim_bike_id AS bike_id,                    -- Unique bike identifier
    COUNT(*) AS trip_count,                      -- Total trips per bike
    ROUND(AVG(f.fact_trip_duration),2) AS avg_trip_duration  -- Mean trip duration (seconds)
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_bike b
    ON f.fact_trip_bike_id = b.dim_bike_id
GROUP BY
    b.dim_bike_id;
```

- **Refresh Strategy**:
  - `Complete refresh`
  - averages (AVG) require full recomputation; refreshed post-load for ongoing utilization analysis.
- **Tablespace**:
  - `MV_TBSP`
- **Schema**:
  - `dw_schema`
- **Partitioning**:
  - None
- **Indexing**:
  - None -->

---

### KPI: User Type Trend

- **Goal**:

  - Precompute total trips and mean duration by user type to evaluate user segmentation in the bike-sharing system.

- **View Structure**: `MV_USER_TYPE`

| Column           | Description                           |
| ---------------- | ------------------------------------- |
| `trip_count`     | Total trips per user type             |
| `duration_avg`   | Mean trip duration (seconds)          |
| `dim_year`       | Year of trips (e.g., 2025)            |
| `user_type_id`   | Unique user type identifier           |
| `user_type_name` | User type name (e.g., Casual, Member) |

- **Source Query**:

```sql
SELECT
  COUNT(*)                              AS  trip_count      -- Measure: Total trips per user type and year
  , ROUNG(AVG(f.fact_trip_duration),2)  AS  duration_avg    -- Measure: Mean trip duration (seconds)
  , t.dim_time_year                     AS  dim_year        -- Dimension: Year of trips (e.g., 2025)
  , u.dim_user_type_id                  AS  user_type_id    -- Dimension: Unique user type identifier
  , u.dim_user_type_name                AS  user_type_name  -- Dimension: User type name (e.g., Casual, Member)
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_user_type u
  ON f.fact_trip_user_type_id = u.dim_user_type_id
JOIN dw_schema.dim_time t
  ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
  t.dim_time_year
  , u.dim_user_type_id
  , u.dim_user_type_name
ORDER BY
  t.dim_time_year
  , u.dim_user_type_id
  , u.dim_user_type_name;
```

- **Refresh Strategy**:

  - `Complete refresh`
  - averages (AVG) require full recomputation; refreshed post-load for ongoing segmentation analysis.

- **Tablespace**:
  - `MV_TBSP`
- **Schema**:
  - `dw_schema`
- **Partitioning**:
  - None
- **Indexing**:
  - None
