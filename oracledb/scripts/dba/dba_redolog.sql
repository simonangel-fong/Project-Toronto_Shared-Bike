
-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
ALTER SESSION SET CONTAINER = cdb$root;

SHOW con_name;
SHOW user;

ARCHIVE LOG LIST;

-- archived log
SELECT 
    GROUP#,
    THREAD#,
    SEQUENCE#,
    BYTES / 1024 / 1024 AS SIZE_MB,
    MEMBERS,
    STATUS,
    ARCHIVED
FROM 
    V$LOG
ORDER BY GROUP#;

ALTER SYSTEM CHECKPOINT;

-- log file path
SELECT 
    GROUP#,
    MEMBER,
    TYPE,
    IS_RECOVERY_DEST_FILE,
    STATUS
FROM 
    V$LOGFILE
ORDER BY GROUP#, MEMBER;

