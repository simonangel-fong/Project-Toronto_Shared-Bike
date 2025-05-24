
-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
ALTER SESSION SET CONTAINER = cdb$root;

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
SELECT name, value FROM v$sysstat WHERE name LIKE '%checkpoint%';

--checkpoint every 30 seconds
ALTER SYSTEM SET FAST_START_MTTR_TARGET = 30 SCOPE = BOTH;
show parameter FAST_START_MTTR_TARGET;

SELECT ESTIMATED_MTTR FROM V$INSTANCE_RECOVERY;

-- add log group
ALTER DATABASE ADD LOGFILE GROUP 6 
  ('/opt/oracle/oradata/ORCLCDB/redo06a.log','/opt/oracle/oradata/ORCLCDB/redo06b.log') SIZE 200M;
ALTER DATABASE ADD LOGFILE GROUP 5 
  ('/opt/oracle/oradata/ORCLCDB/redo05a.log') SIZE 200M;

-- add group member
ALTER DATABASE ADD LOGFILE MEMBER 
  '/opt/oracle/oradata/ORCLCDB/redo01b.log' TO GROUP 1;
ALTER DATABASE ADD LOGFILE MEMBER 
  '/opt/oracle/oradata/ORCLCDB/redo02c.log' TO GROUP 2;
ALTER DATABASE ADD LOGFILE MEMBER 
  '/opt/oracle/oradata/ORCLCDB/redo03b.log' TO GROUP 3;
ALTER DATABASE ADD LOGFILE MEMBER 
  '/opt/oracle/oradata/ORCLCDB/redo04b.log' TO GROUP 4;
ALTER DATABASE ADD LOGFILE MEMBER 
  '/opt/oracle/oradata/ORCLCDB/redo05b.log' TO GROUP 5;
  
--ALTER DATABASE DROP LOGFILE MEMBER '/opt/oracle/oradata/ORCLCDB/redo02c.log';
  
-- confirm
SELECT GROUP#, MEMBER FROM V$LOGFILE ORDER BY GROUP#;



SELECT GROUP#, MEMBER, STATUS FROM V$LOGFILE WHERE GROUP# = 4;


ALTER DATABASE ADD LOGFILE GROUP 5
  ('/opt/oracle/oradata/ORCLCDB/redo05a.log') SIZE 200M;

ALTER DATABASE ADD LOGFILE MEMBER 
  '/opt/oracle/oradata/ORCLCDB/redo05b.log' TO GROUP 5;

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

SELECT TARGET_MTTR,
       ESTIMATED_MTTR,
       CKPT_BLOCK_WRITES
  FROM V$INSTANCE_RECOVERY;

  ALTER SYSTEM SET LOG_CHECKPOINT_TIMEOUT=0;
   ALTER SYSTEM SET LOG_CHECKPOINT_INTERVAL=0;
   ALTER SYSTEM SET FAST_START_IO_TARGET=0;
   
SHOW PARAMETER NIFORM_LOG_TIMESTAMP_FORMAT;

SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL;

select to_char(start_time, 'dd-mon-yyyy@hh24:mi:ss') "Date", status, operation from v$rman_status;

select name from v$obsolete_parameter where isspecified='TRUE';