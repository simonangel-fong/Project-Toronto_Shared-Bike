ALTER session set container=toronto_shared_bike;
show con_name;
show user;

CREATE TYPE mv_user AS OBJECT (
     user_type                  VARCHAR (255) ,
     dim_year                INT ,
     trip_count                      INT,
     trip_duration          DECIMAL,
     
     
);

/
SELECT *
FROM  DW_SCHEMA.MV_USER_SEGMENTATION;