-- ============================================================================
-- Script Name : 03_create_pdb.sql
-- Purpose     : Create a Pluggable Database (PDB) for the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with SYSDBA privileges in the CDB$ROOT container
-- Notes       : Ensure the Oracle Container Database (CDB) is configured and running
-- ============================================================================

-- Enable server output for debugging or messages
SET SERVEROUTPUT ON;

-- Switch to the root container
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- Create the Toronto Shared Bike PDB
CREATE PLUGGABLE DATABASE toronto_shared_bike 
    ADMIN USER pdb_adm IDENTIFIED BY PDBSecurePassword123
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

-- Display the list of PDBs to confirm creation
SHOW PDBS;