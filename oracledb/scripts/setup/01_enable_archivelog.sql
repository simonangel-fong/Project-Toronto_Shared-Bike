-- ============================================================================
-- Script Name : 01_enable_archivelog.sql
-- Purpose     : Enable ARCHIVELOG mode at the Container Database (CDB) level
-- Author      : Wenhao Fang
-- Date        : 2025-05-03
-- User        : Execute as SYSDBA
-- Notes       : Ensure that the FRA (Fast Recovery Area) is properly configured.
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Shutdown
SHUTDOWN IMMEDIATE;

-- Start CDB in MOUNT mode
STARTUP MOUNT;

-- Enable ARCHIVELOG mode
ALTER DATABASE ARCHIVELOG;

-- Open the CDB
ALTER DATABASE OPEN;

-- Confirm
ARCHIVE LOG LIST;
