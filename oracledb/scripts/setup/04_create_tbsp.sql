-- ============================================================================
-- Script Name : 04_create_tbsp.sql
-- Purpose     : Create tablespaces for fact, dimension, index, staging, and materialized view storage
--               in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the PDB is created and open before running this script
-- ============================================================================

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER=toronto_shared_bike;

-- Display the current container name for verification
SHOW con_name;

-- Display the current user for verification
SHOW user

-- Create FACT_TBSP tablespace for storing fact tables with a 32K block size
CREATE TABLESPACE FACT_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/fact_tbsp01.dbf' SIZE 100M AUTOEXTEND ON NEXT 1G MAXSIZE 50G
    , '/opt/oracle/oradata/ORCLCDB/fact_tbsp02.dbf' SIZE 100M AUTOEXTEND ON NEXT 1G MAXSIZE 50G
BLOCKSIZE 32K
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO
LOGGING
ONLINE;

-- Create DIM_TBSP tablespace for storing dimension tables with an 8K block size
CREATE TABLESPACE DIM_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/dim_tbsp01.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 5G
    , '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/dim_tbsp02.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 5G
BLOCKSIZE 8K     
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO
LOGGING
ONLINE;  

-- Create INDEX_TBSP tablespace for storing indexes with an 8K block size
CREATE TABLESPACE INDEX_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/index_tbsp01.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 5G
    , '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/index_tbsp02.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 5G
BLOCKSIZE 8K 
EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
SEGMENT SPACE MANAGEMENT AUTO 
LOGGING 
ONLINE; 
  
-- Create STAGING_TBSP tablespace for storing staging tables with an 8K block size
CREATE TABLESPACE STAGING_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/stage01.dbf' SIZE 1G AUTOEXTEND ON NEXT 500M MAXSIZE 10G
    , '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/stage02.dbf' SIZE 1G AUTOEXTEND ON NEXT 500M MAXSIZE 10G
BLOCKSIZE 8K 
EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
SEGMENT SPACE MANAGEMENT AUTO 
LOGGING 
ONLINE;

-- Create MV_TBSP tablespace for storing materialized views
CREATE TABLESPACE MV_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/MV_TBSP01.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 2G
    , '/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/MV_TBSP02.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 2G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

-- Confirm the creation of tablespaces by listing those with names ending in '_TBSP'
SELECT 
    tablespace_name
FROM DBA_tablespaces
WHERE tablespace_name LIKE '%_TBSP';