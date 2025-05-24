-- ============================================================================
-- Script Name : data analysis.sql
-- Purpose     : 
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : 
-- Notes       : 
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

SELECT COUNT(*)
FROM dw_schema.fact_trip;
