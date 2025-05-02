-- ELT-Extraction
SET SERVEROUTPUT ON;
alter session set container = toronto_shared_bike;

-- Create directory
create or replace directory dir_target 
as '/project/data/2019';

-- Grant read permissions
grant read on directory dir_target to dw_schema;

-- alter dir
alter table dw_schema.external_ridership
   default directory dir_target;

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