-- ============================================================================
-- Script Name : create_dpump.sql
-- Purpose     : Create users for data engineer in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the DW_SCHEMA and materialized views are created before running
-- ============================================================================


-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- ========================================================
-- Create user for data engineer
-- ========================================================
-- Create the data engineer with a secure password
CREATE USER dataEngineer IDENTIFIED BY "SecurePassword!23";
-- Grant session creation and the data engineer to the user
GRANT create session, roleDataEngineer TO dataEngineer;

ALTER USER dataEngineer DEFAULT TABLESPACE SYSTEM QUOTA UNLIMITED ON SYSTEM;

CREATE OR REPLACE DIRECTORY dpump_dir AS '/project/dpump';
GRANT READ, WRITE ON DIRECTORY dpump_dir TO dataEngineer;
GRANT EXP_FULL_DATABASE, IMP_FULL_DATABASE TO dataEngineer;

-- ========================================================
-- Confirm
-- ========================================================
SELECT 
    username
    , account_status
FROM dba_users
WHERE username IN ('DATAENGINEER');