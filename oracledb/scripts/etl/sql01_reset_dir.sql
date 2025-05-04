-- ELT-Extraction
SET SERVEROUTPUT ON;
alter session set container = toronto_shared_bike;

-- Create directory
create or replace directory dir_target 
as '/project/data/2024';

-- Grant read permissions
grant read on directory dir_target to dw_schema;

-- alter dir
alter table dw_schema.external_ridership
   default directory dir_target;
   
-- confirm
SELECT directory_path 
FROM all_directories 
WHERE directory_name = UPPER('dir_target');
