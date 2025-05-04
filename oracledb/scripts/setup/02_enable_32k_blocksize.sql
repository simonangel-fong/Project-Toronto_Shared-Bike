-- ============================================================================
-- Script Name : 02_enable_32k_blocksize.sql
-- Purpose     : Enable 32KB block size support at the Container Database (CDB) level
-- Author      : Wenhao Fang
-- Date        : 2025-05-03
-- Role        : Execute as SYSDBA
-- Notes       : 32K block size requires a dedicated buffer cache. Ensure the SPFILE is in use.
-- ============================================================================

ALTER SESSION SET CONTAINER = CDB$ROOT;

-- Set 32K block size buffer cache (applies to SPFILE only)
ALTER SYSTEM SET DB_32K_CACHE_SIZE = 256M SCOPE = SPFILE;

-- Restart the CDB for the change to take effect
SHUTDOWN IMMEDIATE;
STARTUP;

-- Verify the new cache size setting
SHOW PARAMETER db_32k_cache_size;
