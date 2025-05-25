ALTER session set container = toronto_shared_bike;
show user;
show con_name;

-- user type
SELECT
    dim_user_type_id        
    , dim_user_type_name     
FROM dw_schema.dim_user_type;

-- user type trend
SELECT 
    tm.dim_time_year                AS  dim_year
    , ut.dim_user_type_id           AS  dim_user_type_id
    , COUNT(*)                      AS  trip_year_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , ut.dim_user_type_id
ORDER BY
    tm.dim_time_year
    , ut.dim_user_type_id;

--Trip trend monthly
SELECT 
    tm.dim_time_year                AS  dim_year
    , ut.dim_user_type_id           AS  dim_user_type_id
    , tm.dim_time_month             AS  dim_month
    , COUNT(*)                      AS  trip_month_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , ut.dim_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_month
    , ut.dim_user_type_id;

--Trip trend hourly
SELECT 
    tm.dim_time_year                        AS  dim_year
    , ut.dim_user_type_id                   AS  dim_user_type_id
    , tm.dim_time_hour                      AS  dim_hour
    , COUNT(*)                              AS  trip_hourly_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ut.dim_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ut.dim_user_type_id;

-- Duration Trend monthly
SELECT 
    tm.dim_time_year                            AS  dim_year
    , ut.dim_user_type_id                       AS  dim_user_type_id
    , tm.dim_time_month                         AS  dim_month
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_month_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , ut.dim_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_month
    , ut.dim_user_type_id;

--Duration trend hourly
SELECT 
    tm.dim_time_year                            AS  dim_year
    , ut.dim_user_type_id                       AS  dim_user_type_id
    , tm.dim_time_hour                          AS  dim_hour
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_hourly_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ut.dim_user_type_id
ORDER BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ut.dim_user_type_id;
 
-- Top 10 route trend
SELECT
    dim_year                        AS  dim_year
    , user_type_id                  AS  user_type_id
    , start_station                 AS  dim_start_station
    , end_station                   AS  dim_end_station
    , trip_count                    AS  trip_route_count
FROM (
    SELECT
        dt.dim_time_year            AS  dim_year
        , ut.dim_user_type_id       AS  user_type_id
        , st.dim_station_name       AS  start_station
        , et.dim_station_name       AS  end_station
        , COUNT(*)                  AS  trip_count
        , RANK() OVER (
            PARTITION BY dt.dim_time_year, ut.dim_user_type_id
            ORDER BY COUNT(*) DESC
        )   AS  route_rank
    FROM dw_schema.fact_trip ft
    JOIN dw_schema.dim_station st
        ON ft.fact_trip_start_station_id = st.dim_station_id
    JOIN dw_schema.dim_station et
        ON ft.fact_trip_end_station_id = et.dim_station_id
    JOIN dw_schema.dim_time dt
        ON ft.fact_trip_start_time_id = dt.dim_time_id
    JOIN dw_schema.dim_user_type ut
        ON ft.fact_trip_user_type_id = ut.dim_user_type_id
    WHERE
        UPPER(TRIM(st.dim_station_name)) <> 'UNKNOWN'
        AND UPPER(TRIM(et.dim_station_name)) <> 'UNKNOWN'
        AND st.dim_station_name <> et.dim_station_name
    GROUP BY
        dt.dim_time_year
        , ut.dim_user_type_id
        , st.dim_station_name
        , et.dim_station_name
)
WHERE route_rank <= 10
ORDER BY 
    dim_year
    , user_type_id
    , route_rank;

-- Top 10 station trend
SELECT
    dim_year                        AS  dim_year
    , user_type_id                  AS  user_type_id
    , start_station                 AS  dim_start_station
    , trip_count                    AS  trip_start_station_count
FROM (
    SELECT
        dt.dim_time_year            AS  dim_year
        , ut.dim_user_type_id       AS  user_type_id
        , st.dim_station_name       AS  start_station
        , COUNT(*)                  AS  trip_count
        , RANK() OVER (PARTITION BY dt.dim_time_year, ut.dim_user_type_id
            ORDER BY COUNT(*) DESC
        )   AS  station_rank
    FROM dw_schema.fact_trip ft
    JOIN dw_schema.dim_station st
        ON ft.fact_trip_start_station_id = st.dim_station_id
    JOIN dw_schema.dim_time dt
        ON ft.fact_trip_start_time_id = dt.dim_time_id
    JOIN dw_schema.dim_user_type ut
        ON ft.fact_trip_user_type_id = ut.dim_user_type_id
    WHERE
        UPPER(TRIM(st.dim_station_name)) <> 'UNKNOWN'
    GROUP BY
        dt.dim_time_year
        , ut.dim_user_type_id
        , st.dim_station_name
)
WHERE station_rank <= 10
ORDER BY 
    dim_year
    , user_type_id
    , station_rank;


