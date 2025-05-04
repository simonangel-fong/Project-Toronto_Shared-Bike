-- ELT-Extraction
SET SERVEROUTPUT ON;
alter session set container = toronto_shared_bike;

-- show current dir
SELECT directory_path 
FROM all_directories 
WHERE directory_name = UPPER('dir_target');

-- apply dir
ALTER TABLE dw_schema.external_ridership
DEFAULT DIRECTORY dir_target;

-- confirm
select *
  from dw_schema.external_ridership
 where rownum < 10;

-- Truncate the staging table
truncate table dw_schema.staging_trip;

-- Extract to Staging
insert /*+ APPEND */ into dw_schema.staging_trip
   select *
     from dw_schema.external_ridership;

commit;

-- confirm
select count(*)
from dw_schema.staging_trip
order by start_time;