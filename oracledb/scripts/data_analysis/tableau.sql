ALTER session set container = toronto_shared_bike;
show user;
show con_name;

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
