-- ============================================================================
-- Script Name : 03_create_pdb.sql
-- Purpose     : Create a Pluggable Database (PDB) for the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with SYSDBA privileges in the CDB$ROOT container
-- Notes       : Ensure the Oracle Container Database (CDB) is configured and running
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the root container
ALTER SESSION SET CONTAINER = CDB$ROOT;
SHOW con_name;
SHOW user;

-- Create the Toronto Shared Bike PDB
CREATE PLUGGABLE DATABASE toronto_shared_bike 
    ADMIN USER pdb_adm IDENTIFIED BY "SecurePassword!23"
    ROLES = (DBA)
    DEFAULT TABLESPACE users 
    DATAFILE 
        '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/users01.dbf' SIZE 1M AUTOEXTEND ON NEXT 1M
    FILE_NAME_CONVERT=(
        '/opt/oracle/oradata/ORCLCDB/pdbseed'
        ,'/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/');

-- Open the newly created PDB
ALTER PLUGGABLE DATABASE toronto_shared_bike OPEN;

-- Save the state of the PDB to ensure it opens automatically on CDB restart
ALTER PLUGGABLE DATABASE toronto_shared_bike SAVE STATE;

-- Confirm
SHOW PDBS;