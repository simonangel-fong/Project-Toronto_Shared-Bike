ALTER session set container = toronto_shared_bike;

DESC dw_schema.mv_trip_summary

-- yearly trip count
SELECT 
    trip_year
    , trip_user_type
    , SUM(trip_count) AS trip_yearly_count
FROM dw_schema.mv_trip_summary
GROUP BY 
    trip_year
    , trip_user_type
ORDER BY
    trip_year
    , trip_user_type;

-- monthly trip count
SELECT 
    trip_year
    , trip_month
    , trip_user_type
    , SUM(trip_count) AS trip_monthly_count
FROM dw_schema.mv_trip_summary
GROUP BY 
    trip_year
    , trip_month
    , trip_user_type
ORDER BY     
    trip_year
    , trip_month
    , trip_user_type;
    
-- hourly trip count
SELECT 
    trip_year
    , trip_hour
    , trip_user_type
    , SUM(trip_count) AS trip_hourly_count
FROM dw_schema.mv_trip_summary
GROUP BY 
    trip_year
    , trip_hour
    , trip_user_type
ORDER BY     
    trip_year
    , trip_hour
    , trip_user_type;
    
-- top 10 popular station
SELECT
    trip_year
    , trip_start_station
    , trip_user_type
    , SUM(trip_count) AS trip_station_count
FROM dw_schema.mv_trip_summary
WHERE trip_start_station <> 'UNKNOWN'
GROUP BY 
    trip_year
    , trip_start_station
    , trip_user_type
ORDER BY     
    trip_year
    , trip_user_type
    , SUM(trip_count) DESC
    , trip_start_station
FETCH FIRST 10 ROWS ONLY;

-- TOP 10 popular route
SELECT
    trip_year
    , trip_start_station
    , trip_end_station
    , SUM(trip_count) AS trip_route_count
FROM dw_schema.mv_trip_summary
WHERE 
    trip_year = 2020
    AND trip_start_station <> 'UNKNOWN'
    AND trip_end_station <> 'UNKNOWN'
GROUP BY 
    trip_year
    , trip_start_station
    , trip_end_station
ORDER BY     
    trip_year
    , SUM(trip_count) DESC
FETCH FIRST 10 ROWS ONLY;