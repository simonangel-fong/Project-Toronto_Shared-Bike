-- ============================================================================
-- Script Name : 00_reset_dir.sql
-- Purpose     : Set the directory object for staging data for a specific year
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a privileged user with access to the toronto_shared_bike PDB
-- Notes       : Assumes the procedure `update_directory_for_year` exists in the current schema
-- ============================================================================

-- Switch to the application PDB
ALTER SESSION SET container=toronto_shared_bike;

-- Call the procedure to update the directory object for the year 2024
BEGIN
    update_directory_for_year(2024);
END;
/
