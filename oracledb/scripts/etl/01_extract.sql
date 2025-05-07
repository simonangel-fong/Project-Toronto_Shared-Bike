-- ============================================================================
-- Script Name : 01_extract.sql
-- Purpose     : Perform the Extraction step in the ELT process by loading data 
--               from an external table into a staging table in the Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure that the external file is accessible through the directory `dir_target`
-- ============================================================================

-- Enable server output for debugging or messages
SET SERVEROUTPUT ON;

-- Switch to the application PDB
ALTER SESSION SET container = toronto_shared_bike;

-- Display the path of the directory object used for external table access
SELECT directory_path 
FROM all_directories 
WHERE directory_name = UPPER('dir_target');

-- Set the default directory for the external table
ALTER TABLE dw_schema.external_ridership
DEFAULT DIRECTORY dir_target;

-- Confirm external table access (show a sample row)
SELECT *
FROM dw_schema.external_ridership
WHERE ROWNUM < 2;

-- Truncate the staging table before loading new data
TRUNCATE TABLE dw_schema.staging_trip;

-- Extract data from the external table to the staging table
INSERT /*+ APPEND */ INTO dw_schema.staging_trip
SELECT *
FROM dw_schema.external_ridership;

-- Commit the inserted data
COMMIT;

-- Confirm data was extracted to staging
SELECT COUNT(*)
FROM dw_schema.staging_trip
ORDER BY start_time;
