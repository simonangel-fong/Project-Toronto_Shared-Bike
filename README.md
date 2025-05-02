# Project: Toronto Shared Bike Data Analysis

A repo of data analysis project for Toronto shared bike.

- [Project: Toronto Shared Bike Data Analysis](#project-toronto-shared-bike-data-analysis)
  - [Data Warehouse (Oracle 19c)](#data-warehouse-oracle-19c)

---

## Data Warehouse (Oracle 19c)

- Data Warehouse Design

  - [Conceptual Design](./doc/feature-oracledb/dw_design/conceptual_design/conceptual_design.md)
  - [Logical Design](./doc/feature-oracledb/dw_design/logical_design/logical_design.md)
  - [Physical Design](./doc/feature-oracledb/dw_design/physical_design/physical_design.md)
    - [ETL Design](./doc/feature-oracledb/dw_design/etl_design/etl_design.md)
    - [Materialized View Design](./doc/feature-oracledb/dw_design/mv_design/mv_design.md)

- Data Warehouse Development

  - [Docker Compose Oracle 19c](./doc/feature-oracledb/dw_development/docker-compose/docker-compose.md)
  - [Setup SQL Script](./doc/feature-oracledb/dw_development/setup_script/setup_script.md)

- Data Warehouse Deployment
  - [RHEL 9.3 Deployment](./doc/feature-oracledb/dw_development/rhel_deploy/rhel_deploy.md)



CREATE PLUGGABLE DATABASE toronto_shared_bike 
    ADMIN USER pdb_adm IDENTIFIED BY PDBSecurePassword123
    ROLES = (DBA)
    DEFAULT TABLESPACE users 
    FILE_NAME_CONVERT=(
        '/opt/oracle/oradata/ORCLCDB/pdbseed'
        ,'/opt/oracle/oradata/ORCLCDB/toronto_shared_bike/');