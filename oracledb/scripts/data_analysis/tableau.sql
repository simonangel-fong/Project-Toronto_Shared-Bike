ALTER session set container = toronto_shared_bike;
show user;
show con_name;

-- query user type
SELECT 
    dim_user_type_id        AS dim_user
    , dim_user_type_name    AS user_type
FROM dw_schema.dim_user_type;

-- Aggregate trip count on year and user
SELECT 
    tm.dim_time_year                AS dim_year
    , ft.fact_trip_user_type_id     AS dim_user
    , COUNT(*)                      AS trip_year_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
    , ft.fact_trip_user_type_id
ORDER BY
    tm.dim_time_year
    , ft.fact_trip_user_type_id;

-- Aggregate trip count on year, month and user
SELECT 
    tm.dim_time_year                AS dim_year
    , tm.dim_time_month             AS dim_month
    , ft.fact_trip_user_type_id     AS dim_user
    , COUNT(*)                      AS trip_month_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , ft.fact_trip_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_month
    , ft.fact_trip_user_type_id;

-- Aggregate trip count on year, hour, and user
SELECT 
    tm.dim_time_year                AS dim_year
    , tm.dim_time_hour              AS dim_hour
    , ft.fact_trip_user_type_id     AS dim_user
    , COUNT(*)                      AS trip_hour_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ft.fact_trip_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ft.fact_trip_user_type_id;

----------------------
-- Aggregate average duration on time dimension and user type dimension
SELECT 
    tm.dim_time_year                          AS dim_year
    , tm.dim_time_month                         AS dim_month
    , tm.dim_time_day                           AS dim_day
    , tm.dim_time_weekday                       AS dim_weekday
    , tm.dim_time_hour                          AS dim_hour
    , ft.fact_trip_user_type_id                 AS dim_user
    , COUNT(*)                                  AS trip_count
    , SUM(ft.fact_trip_duration)                AS duration_sum
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
    
-----------------

-- Aggregate trip
SELECT 
    tm.dim_time_year                                        AS dim_year
    , TO_CHAR(TO_DATE(tm.dim_time_month, 'MM'), 'MON')      AS dim_month
    , tm.dim_time_hour                                      AS dim_hour
    , ut.dim_user_type_name                                 AS dim_user_type
    , COUNT(*)                                              AS trip_count
    , SUM(ft.fact_trip_duration)                            AS duration_sum
    , ROUND(AVG(ft.fact_trip_duration),2)                   AS duration_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , tm.dim_time_hour
    , ut.dim_user_type_name 
ORDER BY
    tm.dim_time_year
    , tm.dim_time_month
    , tm.dim_time_hour
    , ut.dim_user_type_name; 

-- Popular station
SELECT
    st.dim_station_name AS start_station,
    et.dim_station_name AS end_station,
    COUNT(*) AS trip_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_station st
    ON ft.fact_trip_start_station_id = st.dim_station_id
JOIN dw_schema.dim_station et
    ON ft.fact_trip_end_station_id = et.dim_station_id
WHERE 
    LOWER(TRIM(st.dim_station_name)) <> 'unknown'
    AND LOWER(TRIM(et.dim_station_name)) <> 'unknown'
    AND st.dim_station_name < et.dim_station_name
GROUP BY
    st.dim_station_name,
    et.dim_station_name
ORDER BY
    trip_count DESC
FETCH FIRST 10 ROWS ONLY;

-- route
SELECT
    dim_year,
    start_station,
    end_station,
    trip_count
FROM (
    SELECT
        dt.dim_time_year        AS dim_year
        , st.dim_station_name AS start_station
        , et.dim_station_name AS end_station
        , COUNT(*) AS trip_count
        , RANK() OVER (PARTITION BY dt.dim_time_year ORDER BY COUNT(*) DESC) AS route_rank
    FROM dw_schema.fact_trip ft
    JOIN dw_schema.dim_station st
        ON ft.fact_trip_start_station_id = st.dim_station_id
    JOIN dw_schema.dim_station et
        ON ft.fact_trip_end_station_id = et.dim_station_id
    JOIN dw_schema.dim_time dt
        ON ft.fact_trip_start_time_id = dt.dim_time_id
    WHERE
        UPPER(TRIM(st.dim_station_name)) <> 'UNKNOWN'
        AND UPPER(TRIM(et.dim_station_name)) <> 'UNKNOWN'
        AND st.dim_station_name <> et.dim_station_name
    GROUP BY
        dt.dim_time_year
        , st.dim_station_name
        , et.dim_station_name
)
WHERE route_rank <= 10
ORDER BY dim_year, route_rank;


