# Proxmox Installation

[Back](../../../README.md)

- [Proxmox Installation](#proxmox-installation)
  - [Monitor Node](#monitor-node)
  - [Application Node](#application-node)
  - [Test deploy](#test-deploy)

---

## Monitor Node

| Path                               | Description                           |
| ---------------------------------- | ------------------------------------- |
| `/project/share/`                  | Dir to share files                    |
| `/project/share/config/oraenv/`    | Environment Files for Oracle Database |
| `/project/share/config/aipenv/`    | Environment Files for API             |
| `/project/share/orcldb/orabackup/` | Oracle DB remote backup files         |

---

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.10/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname monitor-host
sudo cat <<EOF >> /etc/hosts
192.168.128.10      monitor-host
127.0.0.1           monitor-host
EOF

# monitor node file
# local dir
sudo mkdir -pv /project/local/orcldb/orabackup/
sudo mkdir -pv /project/local/orcldb/oradata/

sudo chmod 777 -R /project
```

---

## Application Node

| App Path                           | NFS Path                           | Description                           |
| ---------------------------------- | ---------------------------------- | ------------------------------------- |
| `/project/share/`                  | `/project/share/`                  | Dir to share files                    |
| `/project/share/config/oraenv/`    | `/project/share/config/oraenv/`    | Environment Files for Oracle Database |
| `/project/share/config/aipenv/`    | `/project/share/config/aipenv/`    | Environment Files for API             |
| `/project/share/orcldb/orabackup/` | `/project/share/orcldb/orabackup/` | Oracle DB backup files                |
| `/project/share/data/`             | `/project/share/data/`             | Source Data                           |

| App Path                           | Description                  |
| ---------------------------------- | ---------------------------- |
| `/project/local/`                  | Dir of local files           |
| `/project/local/orcldb/oradata/`   | Oracle DB local data files   |
| `/project/local/orcldb/orabackup/` | Oracle DB local backup files |

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.100/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname application-node
sudo cat <<EOF >> /etc/hosts
192.168.128.10      application-node
127.0.0.1           application-node
EOF
```

- Install Docker

```sh
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

sudo docker run hello-world

sudo usermod -aG docker jenkins

sudo chown root:docker /var/run/docker.sock

sudo chmod 666 /var/run/docker.sock
```

---

## Test deploy

```sh
git clone -b feature-oracledb https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git .

docker compose -f compose.oracledb.prod.yaml up --build -d

docker exec -it oracle19cDB bash

```


```conf
 docker logs oracle19cDB
ORACLE EDITION: ENTERPRISE

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 05-MAY-2025 05:54:33

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Starting /opt/oracle/product/19c/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/9af425025223/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                05-MAY-2025 05:54:33
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/9af425025223/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
The listener supports no services
The command completed successfully
[WARNING] [DBT-06208] The 'SYS' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06208] The 'SYSTEM' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06208] The 'PDBADMIN' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
Prepare for db operation
Cannot create directory "/opt/oracle/oradata/ORCLCDB".
8% complete
Copying database files
31% complete
100% complete
[FATAL] Recovery Manager failed to restore datafiles. Refer logs for details.
8% complete
0% complete
Look at the log file "/opt/oracle/cfgtoollogs/dbca/ORCLCDB/ORCLCDB.log" for further details.
[ 2025-05-05 05:54:40.306 UTC ] [WARNING] [DBT-06208] The 'SYS' password entered does not conform to the Oracle recommended standards.
[ 2025-05-05 05:54:40.306 UTC ] [WARNING] [DBT-06208] The 'SYSTEM' password entered does not conform to the Oracle recommended standards.
[ 2025-05-05 05:54:40.306 UTC ] [WARNING] [DBT-06208] The 'PDBADMIN' password entered does not conform to the Oracle recommended standards.
[ 2025-05-05 05:54:42.271 UTC ] Prepare for db operation
[ 2025-05-05 05:54:42.306 UTC ] Cannot create directory "/opt/oracle/oradata/ORCLCDB".
DBCA_PROGRESS : 8%
[ 2025-05-05 05:54:42.309 UTC ] Copying database files
DBCA_PROGRESS : 31%
DBCA_PROGRESS : 100%
[ 2025-05-05 05:55:00.727 UTC ] [FATAL] Recovery Manager failed to restore datafiles. Refer logs for details.
DBCA_PROGRESS : 8%
DBCA_PROGRESS : 0%

SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 5 05:55:01 2025
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL>    ALTER SYSTEM SET control_files='/opt/oracle/oradata/ORCLCDB/control01.ctl' scope=spfile
*
ERROR at line 1:
ORA-32001: write to SPFILE requested but no SPFILE is in use


SQL>
System altered.

SQL>    ALTER PLUGGABLE DATABASE PDB1 SAVE STATE
*
ERROR at line 1:
ORA-01109: database not open


SQL> BEGIN DBMS_XDB_CONFIG.SETGLOBALPORTENABLED (TRUE); END;

      *
ERROR at line 1:
ORA-06550: line 1, column 7:
PLS-00201: identifier 'DBMS_XDB_CONFIG.SETGLOBALPORTENABLED' must be declared
ORA-06550: line 1, column 7:
PL/SQL: Statement ignored


SQL> SQL>
Session altered.

SQL>    CREATE USER OPS$oracle IDENTIFIED EXTERNALLY
*
ERROR at line 1:
ORA-01109: database not open


SQL>    GRANT CREATE SESSION TO OPS$oracle
*
ERROR at line 1:
ORA-01109: database not open


SQL>    GRANT SELECT ON sys.v_$pdbs TO OPS$oracle
*
ERROR at line 1:
ORA-01109: database not open


SQL>    GRANT SELECT ON sys.v_$database TO OPS$oracle
*
ERROR at line 1:
ORA-01109: database not open


SQL>    ALTER USER OPS$oracle SET container_data=all for sys.v_$pdbs container = current
*
ERROR at line 1:
ORA-01109: database not open


SQL> SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
ORACLE_HOME = [/home/oracle] ? ORACLE_BASE environment variable is not being set since this
information is not available for the current user ID .
You can set ORACLE_BASE manually if it is required.
Resetting ORACLE_BASE to its previous value or ORACLE_HOME
The Oracle base remains unchanged with value /opt/oracle
/opt/oracle/checkDBStatus.sh: line 26: sqlplus: command not found
mkdir: cannot create directory '/opt/oracle/oradata/dbconfig': Permission denied
mv: cannot stat '/opt/oracle/product/19c/dbhome_1/dbs/spfileORCLCDB.ora': No such file or directory
mv: cannot stat '/opt/oracle/product/19c/dbhome_1/dbs/orapwORCLCDB': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/install/.docker_enterprise' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
cp: cannot create regular file '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
ln: failed to create symbolic link '/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora': File exists
ln: failed to create symbolic link '/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora': File exists
ln: failed to create symbolic link '/opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora': File exists
cp: cannot stat '/opt/oracle/oradata/dbconfig/ORCLCDB/oratab': No such file or directory

Executing user defined scripts
/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/01_enable_archivelog.sql
ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3
ORA-01081: cannot start already-running ORACLE - shut it down first
ALTER DATABASE ARCHIVELOG
*
ERROR at line 1:
ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3


ALTER DATABASE OPEN
*
ERROR at line 1:
ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3


ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3


/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/02_enable_32k_blocksize.sql

Session altered.

ALTER SYSTEM SET DB_32K_CACHE_SIZE = 256M SCOPE = SPFILE
*
ERROR at line 1:
ORA-32001: write to SPFILE requested but no SPFILE is in use


ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3
ORA-01081: cannot start already-running ORACLE - shut it down first

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_32k_cache_size                    big integer 0


/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/03_create_pdb.sql

Session altered.

CREATE PLUGGABLE DATABASE toronto_shared_bike
*
ERROR at line 1:
ORA-01109: database not open


ALTER PLUGGABLE DATABASE toronto_shared_bike OPEN
*
ERROR at line 1:
ORA-01109: database not open


ALTER PLUGGABLE DATABASE toronto_shared_bike SAVE STATE
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/04_create_tbsp.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.



CON_NAME
------------------------------
CDB$ROOT
USER is "SYS"
CREATE TABLESPACE FACT_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE DIM_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE INDEX_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE STAGING_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE MV_TBSP
*
ERROR at line 1:
ORA-01109: database not open


FROM DBA_tablespaces
     *
ERROR at line 3:
ORA-01219: database or pluggable database not open: queries allowed on fixed
tables or views only




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/05_create_schema.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE USER DW_SCHEMA
*
ERROR at line 1:
ORA-01109: database not open


GRANT CREATE TABLE TO DW_SCHEMA
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/06_create_dw.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE TABLE DW_SCHEMA.dim_time (
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_dim_time_date
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_dim_time_year_month
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.dim_station (
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_dim_station_station_name
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.dim_bike (
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.dim_user_type (
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.fact_trip (
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_fact_trip_start_time
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_fact_trip_station_pair
*
ERROR at line 1:
ORA-01109: database not open


CREATE BITMAP INDEX DW_SCHEMA.index_fact_trip_user_type
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/07_create_etl.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE OR REPLACE DIRECTORY data_dir
*
ERROR at line 1:
ORA-01109: database not open


GRANT READ ON DIRECTORY data_dir TO DW_SCHEMA
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.external_ridership (
*
ERROR at line 1:
ORA-01109: database not open


ALTER USER DW_SCHEMA QUOTA UNLIMITED ON STAGING_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.staging_trip (
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/08_create_etl_procedure.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE OR REPLACE PROCEDURE update_directory_for_year(p_year IN VARCHAR2) IS
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/09_create_mv.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.fact_trip
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.dim_time
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.dim_station
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_TIME_TRIP
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE INDEX DW_SCHEMA.idx_mv_time_trip_year_month
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.idx_mv_time_trip_year_hour
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_STATION_TRIP
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_STATION_ROUTE
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_BIKE_TRIP_DURATION
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_USER_SEGMENTATION
*
ERROR at line 1:
ORA-01435: user does not exist




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/10_create_user.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.



CON_NAME
------------------------------
CDB$ROOT
USER is "SYS"
CREATE ROLE apiTesterRole
*
ERROR at line 1:
ORA-01109: database not open


GRANT SELECT ON DW_SCHEMA.MV_USER_SEGMENTATION TO apiTesterRole
*
ERROR at line 1:
ORA-01109: database not open


CREATE USER apiTester1 IDENTIFIED BY "apiTester123"
*
ERROR at line 1:
ORA-01109: database not open


GRANT create session, apiTesterRole TO apiTester1
*
ERROR at line 1:
ORA-01109: database not open




DONE: Executing user defined scripts

ORACLE_HOME = [/home/oracle] ? ORACLE_BASE environment variable is not being set since this
information is not available for the current user ID .
You can set ORACLE_BASE manually if it is required.
Resetting ORACLE_BASE to its previous value or ORACLE_HOME
The Oracle base remains unchanged with value /opt/oracle
/opt/oracle/checkDBStatus.sh: line 26: sqlplus: command not found
#####################################
########### E R R O R ###############
DATABASE SETUP WAS NOT SUCCESSFUL!
Please check output for further info!
########### E R R O R ###############
#####################################
The following output is now a tail of the alert.log:
2025-05-05T05:55:02.741677+00:00
ERROR: Shared memory area is accessible to instance startup process
 prior to instance startup operation.
ALTER DATABASE ARCHIVELOG
ORA-210 signalled during: ALTER DATABASE ARCHIVELOG...
ALTER DATABASE OPEN
ORA-210 signalled during: ALTER DATABASE OPEN...
2025-05-05T05:55:03.791587+00:00
ERROR: Shared memory area is accessible to instance startup process
 prior to instance startup operation.
[aadmin@monitor-host oracledb]$ docker logs oracle19cDB
ORACLE EDITION: ENTERPRISE

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 05-MAY-2025 05:54:33

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Starting /opt/oracle/product/19c/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/9af425025223/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                05-MAY-2025 05:54:33
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/9af425025223/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
The listener supports no services
The command completed successfully
[WARNING] [DBT-06208] The 'SYS' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06208] The 'SYSTEM' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
[WARNING] [DBT-06208] The 'PDBADMIN' password entered does not conform to the Oracle recommended standards.
   CAUSE:
a. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].
b.The password entered is a keyword that Oracle does not recommend to be used as password
   ACTION: Specify a strong password. If required refer Oracle documentation for guidelines.
Prepare for db operation
Cannot create directory "/opt/oracle/oradata/ORCLCDB".
8% complete
Copying database files
31% complete
100% complete
[FATAL] Recovery Manager failed to restore datafiles. Refer logs for details.
8% complete
0% complete
Look at the log file "/opt/oracle/cfgtoollogs/dbca/ORCLCDB/ORCLCDB.log" for further details.
[ 2025-05-05 05:54:40.306 UTC ] [WARNING] [DBT-06208] The 'SYS' password entered does not conform to the Oracle recommended standards.
[ 2025-05-05 05:54:40.306 UTC ] [WARNING] [DBT-06208] The 'SYSTEM' password entered does not conform to the Oracle recommended standards.
[ 2025-05-05 05:54:40.306 UTC ] [WARNING] [DBT-06208] The 'PDBADMIN' password entered does not conform to the Oracle recommended standards.
[ 2025-05-05 05:54:42.271 UTC ] Prepare for db operation
[ 2025-05-05 05:54:42.306 UTC ] Cannot create directory "/opt/oracle/oradata/ORCLCDB".
DBCA_PROGRESS : 8%
[ 2025-05-05 05:54:42.309 UTC ] Copying database files
DBCA_PROGRESS : 31%
DBCA_PROGRESS : 100%
[ 2025-05-05 05:55:00.727 UTC ] [FATAL] Recovery Manager failed to restore datafiles. Refer logs for details.
DBCA_PROGRESS : 8%
DBCA_PROGRESS : 0%

SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 5 05:55:01 2025
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL>    ALTER SYSTEM SET control_files='/opt/oracle/oradata/ORCLCDB/control01.ctl' scope=spfile
*
ERROR at line 1:
ORA-32001: write to SPFILE requested but no SPFILE is in use


SQL>
System altered.

SQL>    ALTER PLUGGABLE DATABASE PDB1 SAVE STATE
*
ERROR at line 1:
ORA-01109: database not open


SQL> BEGIN DBMS_XDB_CONFIG.SETGLOBALPORTENABLED (TRUE); END;

      *
ERROR at line 1:
ORA-06550: line 1, column 7:
PLS-00201: identifier 'DBMS_XDB_CONFIG.SETGLOBALPORTENABLED' must be declared
ORA-06550: line 1, column 7:
PL/SQL: Statement ignored


SQL> SQL>
Session altered.

SQL>    CREATE USER OPS$oracle IDENTIFIED EXTERNALLY
*
ERROR at line 1:
ORA-01109: database not open


SQL>    GRANT CREATE SESSION TO OPS$oracle
*
ERROR at line 1:
ORA-01109: database not open


SQL>    GRANT SELECT ON sys.v_$pdbs TO OPS$oracle
*
ERROR at line 1:
ORA-01109: database not open


SQL>    GRANT SELECT ON sys.v_$database TO OPS$oracle
*
ERROR at line 1:
ORA-01109: database not open


SQL>    ALTER USER OPS$oracle SET container_data=all for sys.v_$pdbs container = current
*
ERROR at line 1:
ORA-01109: database not open


SQL> SQL> Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
ORACLE_HOME = [/home/oracle] ? ORACLE_BASE environment variable is not being set since this
information is not available for the current user ID .
You can set ORACLE_BASE manually if it is required.
Resetting ORACLE_BASE to its previous value or ORACLE_HOME
The Oracle base remains unchanged with value /opt/oracle
/opt/oracle/checkDBStatus.sh: line 26: sqlplus: command not found
mkdir: cannot create directory '/opt/oracle/oradata/dbconfig': Permission denied
mv: cannot stat '/opt/oracle/product/19c/dbhome_1/dbs/spfileORCLCDB.ora': No such file or directory
mv: cannot stat '/opt/oracle/product/19c/dbhome_1/dbs/orapwORCLCDB': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
mv: cannot move '/opt/oracle/product/19c/dbhome_1/install/.docker_enterprise' to '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
cp: cannot create regular file '/opt/oracle/oradata/dbconfig/ORCLCDB/': No such file or directory
ln: failed to create symbolic link '/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora': File exists
ln: failed to create symbolic link '/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora': File exists
ln: failed to create symbolic link '/opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora': File exists
cp: cannot stat '/opt/oracle/oradata/dbconfig/ORCLCDB/oratab': No such file or directory

Executing user defined scripts
/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/01_enable_archivelog.sql
ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3
ORA-01081: cannot start already-running ORACLE - shut it down first
ALTER DATABASE ARCHIVELOG
*
ERROR at line 1:
ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3


ALTER DATABASE OPEN
*
ERROR at line 1:
ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3


ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3


/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/02_enable_32k_blocksize.sql

Session altered.

ALTER SYSTEM SET DB_32K_CACHE_SIZE = 256M SCOPE = SPFILE
*
ERROR at line 1:
ORA-32001: write to SPFILE requested but no SPFILE is in use


ORA-00210: cannot open the specified control file
ORA-00202: control file: '/opt/oracle/cfgtoollogs/dbca/ORCLCDB/tempControl.ctl'
ORA-27041: unable to open file
Linux-x86_64 Error: 2: No such file or directory
Additional information: 3
ORA-01081: cannot start already-running ORACLE - shut it down first

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_32k_cache_size                    big integer 0


/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/03_create_pdb.sql

Session altered.

CREATE PLUGGABLE DATABASE toronto_shared_bike
*
ERROR at line 1:
ORA-01109: database not open


ALTER PLUGGABLE DATABASE toronto_shared_bike OPEN
*
ERROR at line 1:
ORA-01109: database not open


ALTER PLUGGABLE DATABASE toronto_shared_bike SAVE STATE
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/04_create_tbsp.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.



CON_NAME
------------------------------
CDB$ROOT
USER is "SYS"
CREATE TABLESPACE FACT_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE DIM_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE INDEX_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE STAGING_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLESPACE MV_TBSP
*
ERROR at line 1:
ORA-01109: database not open


FROM DBA_tablespaces
     *
ERROR at line 3:
ORA-01219: database or pluggable database not open: queries allowed on fixed
tables or views only




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/05_create_schema.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE USER DW_SCHEMA
*
ERROR at line 1:
ORA-01109: database not open


GRANT CREATE TABLE TO DW_SCHEMA
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/06_create_dw.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE TABLE DW_SCHEMA.dim_time (
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_dim_time_date
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_dim_time_year_month
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.dim_station (
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_dim_station_station_name
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.dim_bike (
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.dim_user_type (
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.fact_trip (
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_fact_trip_start_time
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.index_fact_trip_station_pair
*
ERROR at line 1:
ORA-01109: database not open


CREATE BITMAP INDEX DW_SCHEMA.index_fact_trip_user_type
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/07_create_etl.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE OR REPLACE DIRECTORY data_dir
*
ERROR at line 1:
ORA-01109: database not open


GRANT READ ON DIRECTORY data_dir TO DW_SCHEMA
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.external_ridership (
*
ERROR at line 1:
ORA-01109: database not open


ALTER USER DW_SCHEMA QUOTA UNLIMITED ON STAGING_TBSP
*
ERROR at line 1:
ORA-01109: database not open


CREATE TABLE DW_SCHEMA.staging_trip (
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/08_create_etl_procedure.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE OR REPLACE PROCEDURE update_directory_for_year(p_year IN VARCHAR2) IS
*
ERROR at line 1:
ORA-01109: database not open




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/09_create_mv.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.


CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.fact_trip
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.dim_time
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW LOG ON DW_SCHEMA.dim_station
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_TIME_TRIP
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE INDEX DW_SCHEMA.idx_mv_time_trip_year_month
*
ERROR at line 1:
ORA-01109: database not open


CREATE INDEX DW_SCHEMA.idx_mv_time_trip_year_hour
*
ERROR at line 1:
ORA-01109: database not open


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_STATION_TRIP
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_STATION_ROUTE
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_BIKE_TRIP_DURATION
*
ERROR at line 1:
ORA-01435: user does not exist


CREATE MATERIALIZED VIEW DW_SCHEMA.MV_USER_SEGMENTATION
*
ERROR at line 1:
ORA-01435: user does not exist




/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/10_create_user.sql
ERROR:
ORA-65011: Pluggable database TORONTO_SHARED_BIKE does not exist.



CON_NAME
------------------------------
CDB$ROOT
USER is "SYS"
CREATE ROLE apiTesterRole
*
ERROR at line 1:
ORA-01109: database not open


GRANT SELECT ON DW_SCHEMA.MV_USER_SEGMENTATION TO apiTesterRole
*
ERROR at line 1:
ORA-01109: database not open


CREATE USER apiTester1 IDENTIFIED BY "apiTester123"
*
ERROR at line 1:
ORA-01109: database not open


GRANT create session, apiTesterRole TO apiTester1
*
ERROR at line 1:
ORA-01109: database not open




DONE: Executing user defined scripts

ORACLE_HOME = [/home/oracle] ? ORACLE_BASE environment variable is not being set since this
information is not available for the current user ID .
You can set ORACLE_BASE manually if it is required.
Resetting ORACLE_BASE to its previous value or ORACLE_HOME
The Oracle base remains unchanged with value /opt/oracle
/opt/oracle/checkDBStatus.sh: line 26: sqlplus: command not found
#####################################
########### E R R O R ###############
DATABASE SETUP WAS NOT SUCCESSFUL!
Please check output for further info!
########### E R R O R ###############
#####################################
The following output is now a tail of the alert.log:
2025-05-05T05:55:02.741677+00:00
ERROR: Shared memory area is accessible to instance startup process
 prior to instance startup operation.
ALTER DATABASE ARCHIVELOG
ORA-210 signalled during: ALTER DATABASE ARCHIVELOG...
ALTER DATABASE OPEN
ORA-210 signalled during: ALTER DATABASE OPEN...
2025-05-05T05:55:03.791587+00:00
ERROR: Shared memory area is accessible to instance startup process
 prior to instance startup operation.
```