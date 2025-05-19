
-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

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

-- path
SELECT 
    GROUP#,
    MEMBER,
    TYPE,
    IS_RECOVERY_DEST_FILE,
    STATUS
FROM 
    V$LOGFILE
ORDER BY GROUP#, MEMBER;

-- Check current log size
ALTER DATABASE ADD LOGFILE GROUP 4 ('/opt/oracle/oradata/ORCLCDB/redo04.log') SIZE 500M;

SELECT name, value FROM v$sysstat WHERE name LIKE '%checkpoint%';


