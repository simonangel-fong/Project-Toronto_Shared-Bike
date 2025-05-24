-- ============================================================================
-- Script Name : create_mv.sql
-- Purpose     : Create materialized view logs and materialized views for efficient
--               querying and reporting in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with appropriate privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the dw_schema, fact, and dimension tables are created and populated
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- ============================================================================
-- Creating MV LOG
-- ============================================================================

-- Create materialized view log on fact_trip for fast refresh support
--DROP MATERIALIZED VIEW LOG ON dw_schema.fact_trip;
CREATE MATERIALIZED VIEW LOG ON dw_schema.fact_trip
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    fact_trip_start_time_id
    , fact_trip_start_station_id
    , fact_trip_end_station_id
    )
INCLUDING NEW VALUES;

-- Create materialized view log on dim_time for fast refresh support
--DROP MATERIALIZED VIEW LOG ON dw_schema.dim_time;
CREATE MATERIALIZED VIEW LOG ON dw_schema.dim_time
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    dim_time_id
    , dim_time_year
    , dim_time_month
    , dim_time_hour
    )
INCLUDING NEW VALUES;

-- Create materialized view log on dim_station for fast refresh support
--DROP MATERIALIZED VIEW LOG ON dw_schema.dim_station;
CREATE MATERIALIZED VIEW LOG ON dw_schema.dim_station
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    dim_station_id
    , dim_station_name
    )
INCLUDING NEW VALUES;

-- ============================================================================
-- Creating MV for time-based trip analysis
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_trip_time;
CREATE MATERIALIZED VIEW dw_schema.mv_trip_time
TABLESPACE MV_TBSP
PARTITION BY RANGE (dim_year) (
    PARTITION p_before  VALUES LESS THAN (2019)  -- Partition for pre-2019 data
    , PARTITION p_2020  VALUES LESS THAN (2020)  -- Partition for 2020 data
    , PARTITION p_2021  VALUES LESS THAN (2021)  -- Partition for 2021 data
    , PARTITION p_2022  VALUES LESS THAN (2022)  -- Partition for 2022 data
    , PARTITION p_2023  VALUES LESS THAN (2023)  -- Partition for 2023 data
    , PARTITION p_2024  VALUES LESS THAN (2024)  -- Partition for 2024 data
    , PARTITION p_2025  VALUES LESS THAN (2025)  -- Partition for 2025 data
    , PARTITION p_max   VALUES LESS THAN (MAXVALUE)  -- Catch-all partition
)
BUILD IMMEDIATE
REFRESH FAST ON DEMAND  -- Enable incremental updates
ENABLE QUERY REWRITE
AS
SELECT
  COUNT(*)            AS trip_count,
  t.dim_time_year     AS dim_year,
  t.dim_time_month    AS dim_month,
  t.dim_time_hour     AS dim_hour
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
  ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
  t.dim_time_year,
  t.dim_time_month,
  t.dim_time_hour;

-- Create composite B-tree index for year-month queries on mv_trip_time
CREATE INDEX dw_schema.idx_mv_trip_time_year_month
ON dw_schema.mv_trip_time (dim_year, dim_month)
TABLESPACE MV_TBSP;

-- Create composite B-tree index for year-hour queries on mv_trip_time
CREATE INDEX dw_schema.idx_mv_trip_time_year_hour
ON dw_schema.mv_trip_time (dim_year, dim_hour)
TABLESPACE MV_TBSP;

-- ============================================================================
-- Creating MV for time-based duration analysis
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_duration_time;
CREATE MATERIALIZED VIEW dw_schema.mv_duration_time
TABLESPACE MV_TBSP
PARTITION BY RANGE (dim_year) (
    PARTITION p_before  VALUES LESS THAN (2019)  -- Partition for pre-2019 data
    , PARTITION p_2020  VALUES LESS THAN (2020)  -- Partition for 2020 data
    , PARTITION p_2021  VALUES LESS THAN (2021)  -- Partition for 2021 data
    , PARTITION p_2022  VALUES LESS THAN (2022)  -- Partition for 2022 data
    , PARTITION p_2023  VALUES LESS THAN (2023)  -- Partition for 2023 data
    , PARTITION p_2024  VALUES LESS THAN (2024)  -- Partition for 2024 data
    , PARTITION p_2025  VALUES LESS THAN (2025)  -- Partition for 2025 data
    , PARTITION p_max   VALUES LESS THAN (MAXVALUE)  -- Catch-all partition
)
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
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
  , t.dim_time_hour;

-- Create composite B-tree index for year-month queries on mv_duration_time
CREATE INDEX dw_schema.idx_mv_duration_time_year_month
ON dw_schema.mv_duration_time (dim_year, dim_month)
TABLESPACE MV_TBSP;

-- Create composite B-tree index for year-hour queries on mv_duration_time
CREATE INDEX dw_schema.idx_mv_duration_time_year_hour
ON dw_schema.mv_duration_time (dim_year, dim_hour)
TABLESPACE MV_TBSP;

-- ============================================================================
-- Creating MV for station-based trip analysis
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_trip_station;
CREATE MATERIALIZED VIEW dw_schema.mv_trip_station
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH FAST ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
  COUNT(*)              AS  trip_count_by_start   -- Measure: Trips count
  , s.dim_station_id    AS  dim_station_id            -- Dimension: station id
  , s.dim_station_name  AS  dim_station_name          -- Dimension: station name
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
;

-- Create composite B-tree index for year queries on mv_trip_station
CREATE INDEX dw_schema.idx_mv_trip_station_year
ON dw_schema.mv_trip_station (dim_year)
TABLESPACE MV_TBSP;

-- Create composite B-tree index for station queries on mv_trip_station
CREATE INDEX dw_schema.idx_mv_trip_station_station
ON dw_schema.mv_trip_station (dim_station_id)
TABLESPACE MV_TBSP;

-- ============================================================================
-- Creating MV for user segmentation analysis
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_user_type;
CREATE MATERIALIZED VIEW dw_schema.mv_user_type
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
  COUNT(*)                              AS  trip_count      -- Measure: Total trips per user type and year
  , ROUND(AVG(f.fact_trip_duration),2)  AS  duration_avg    -- Measure: Mean trip duration (seconds)
  , t.dim_time_year                     AS  dim_year        -- Dimension: Year of trips (e.g., 2025)
  , u.dim_user_type_id                  AS  dim_user_type_id    -- Dimension: Unique user type identifier
  , u.dim_user_type_name                AS  dim_user_type_name  -- Dimension: User type name (e.g., Casual, Member)
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_user_type u
  ON f.fact_trip_user_type_id = u.dim_user_type_id
JOIN dw_schema.dim_time t
  ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
  t.dim_time_year
  , u.dim_user_type_id
  , u.dim_user_type_name
;
    
-- confirm
SELECT 
    master
    , owner
    , mview_last_refresh_time
FROM ALL_BASE_TABLE_MVIEWS;

SELECT 
    mview_name
    , owner
    , refresh_method
    , last_refresh_date
--    , query
FROM dba_mviews
ORDER BY mview_name;
