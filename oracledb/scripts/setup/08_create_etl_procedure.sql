-- ============================================================================
-- Script Name : 08_create_etl_procedure.sql
-- Purpose     : Create a stored procedure to dynamically update the directory
--               for ELT data extraction based on a specified year
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the DW_SCHEMA and directory privileges are set up before execution
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- Create or replace the procedure to update the directory for a given year
--DROP PROCEDURE UPDATE_DIRECTORY_FOR_YEAR;
CREATE OR REPLACE PROCEDURE UPDATE_DIRECTORY_FOR_YEAR(p_year IN VARCHAR2) IS
    v_path VARCHAR2(1000);      -- Variable to store the directory path
    sql_stmt VARCHAR2(1000);    -- Variable to store dynamic SQL statements
BEGIN
    -- Construct the directory path based on the input year
    v_path := '/project/data/' || p_year;

    -- Create or replace the directory object
    sql_stmt := 'CREATE OR REPLACE DIRECTORY data_dir AS ''' || v_path || '''';
    EXECUTE IMMEDIATE sql_stmt;

    -- Grant read privilege on the directory to DW_SCHEMA
    sql_stmt := 'GRANT READ ON DIRECTORY data_dir TO dw_schema';
    EXECUTE IMMEDIATE sql_stmt;

    -- Output confirmation of directory update
    DBMS_OUTPUT.PUT_LINE('Directory updated to: ' || v_path);
END;
/

-- Confirm
SELECT
    object_name
    , object_type 
    , owner
FROM dba_procedures
WHERE object_name = 'UPDATE_DIRECTORY_FOR_YEAR';
