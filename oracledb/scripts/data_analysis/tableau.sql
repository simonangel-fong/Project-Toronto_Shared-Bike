ALTER session set container = toronto_shared_bike;
show user;
show con_name;

-- query user type
SELECT 
    dim_user_type_id            AS dim_user
    , dim_user_type_name        AS user_nmae
FROM dw_schema.dim_user_type;

-- Aggregate trip count on time dimension and user type dimension
SELECT 
    tm.dim_time_year                AS dim_year
    , tm.dim_time_month             AS dim_month
    , tm.dim_time_day               AS dim_day
    , tm.dim_time_weekday           AS dim_weekday
    , tm.dim_time_hour              AS dim_hour
    , ft.fact_trip_user_type_id     AS dim_user
    , COUNT(*)                      AS trip_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , tm.dim_time_day
    , tm.dim_time_weekday
    , tm.dim_time_hour
    , ft.fact_trip_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_month
    , tm.dim_time_day
    , tm.dim_time_hour
    , ft.fact_trip_user_type_id;
    
-- Aggregate average duration on time dimension and user type dimension
SELECT 
    tm.dim_time_year                          AS dim_year
    , tm.dim_time_month                         AS dim_month
    , tm.dim_time_day                           AS dim_day
    , tm.dim_time_weekday                       AS dim_weekday
    , tm.dim_time_hour                          AS dim_hour
    , ft.fact_trip_user_type_id                 AS dim_user
    , ROUND(AVG(ft.fact_trip_duration),2)       AS avg_duration
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , tm.dim_time_day
    , tm.dim_time_weekday
    , tm.dim_time_hour
    , ft.fact_trip_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_month
    , tm.dim_time_day
    , tm.dim_time_hour
    , ft.fact_trip_user_type_id;
    
-- query to count total for each user type
SELECT
--    /*csv*/
    tm.dim_time_year                AS dim_year
    , ft.fact_trip_user_type_id     AS dim_user
    , COUNT(*)                      AS trip_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
    , ft.fact_trip_user_type_id
ORDER BY
    tm.dim_time_year
    , ft.fact_trip_user_type_id;
    
--
---------------------------------------------------
SELECT 
    COUNT(*)                      AS trip_count
--    , tm.dim_time_year                AS dim_year
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
HAVING tm.dim_time_year = 2019;












