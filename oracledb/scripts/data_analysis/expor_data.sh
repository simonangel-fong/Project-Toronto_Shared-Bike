#!/bin/sh

sqlplus / as sysdba <<EOF

set colsep ,
set headsep off
set pagesize 0
set trimspool on
set linesize 8
set markup csv on

SPOOL "/project/export/yearly_trend.csv";

SELECT /*csv*/  
    trip_year,
    SUM(trip_count) AS trip_yearly_count
FROM dw_schema.mv_trip_summary
GROUP BY trip_year
ORDER BY trip_year;

SPOOL off;

EOF

