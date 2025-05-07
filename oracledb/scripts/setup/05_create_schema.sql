-- ============================================================================
-- Script Name : 05_create_schema.sql
-- Purpose     : Create a dedicated schema (DW_SCHEMA) in the Toronto Shared Bike PDB
--               and assign necessary privileges and quotas
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the PDB and required tablespaces (FACT_TBSP, DIM_TBSP, INDEX_TBSP, STAGING_TBSP, MV_TBSP) are created
-- ============================================================================

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- Create the DW_SCHEMA user with a secure password
CREATE USER DW_SCHEMA
IDENTIFIED BY "DwSchemaSecurePass123"
DEFAULT TABLESPACE FACT_TBSP
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON FACT_TBSP
QUOTA UNLIMITED ON DIM_TBSP
QUOTA UNLIMITED ON INDEX_TBSP
QUOTA UNLIMITED ON STAGING_TBSP
QUOTA UNLIMITED ON MV_TBSP;

-- Grant necessary privileges to DW_SCHEMA
GRANT CREATE TABLE TO DW_SCHEMA; -- Allow creation of tables