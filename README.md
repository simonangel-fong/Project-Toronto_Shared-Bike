# Project: Toronto Shared Bike Data Analysis

A repo of data analysis project for Toronto shared bike.

- [Project: Toronto Shared Bike Data Analysis](#project-toronto-shared-bike-data-analysis)
  - [Data Warehouse (Oracle 19c)](#data-warehouse-oracle-19c)
  - [API](#api)
  - [Devops](#devops)

---

## Data Warehouse (Oracle 19c)

- Data Warehouse Design

  - [Conceptual Design](./doc/feature-oracledb/dw_design/conceptual_design/conceptual_design.md)
  - [Logical Design](./doc/feature-oracledb/dw_design/logical_design/logical_design.md)
  - [Physical Design](./doc/feature-oracledb/dw_design/physical_design/physical_design.md)
    - [ETL Design](./doc/feature-oracledb/dw_design/etl_design/etl_design.md)
    - [Materialized View Design](./doc/feature-oracledb/dw_design/mv_design/mv_design.md)

- Data Warehouse Development

  - [Setup SQL Script](./doc/feature-oracledb/dw_development/setup_script/setup_script.md)
  - [Docker Compose](./doc/feature-oracledb/dw_development/docker_compose/docker_compose.md)
  - [ELT Scripts](./doc/feature-oracledb/dw_development/etl_script/etl_script.md)
  - [Backup Plan & Scripts](./doc/feature-oracledb/dw_development/backup_script/backup_script.md)

- Data Warehouse Deployment
  - [Deployment](./doc/feature-oracledb/dw_deployment/deploy/deploy.md)

---

## API

- [FastAPI Local Build](./doc/feature-api/fastapi/fastapi.md)
- [Pipeline: Oracle+FastAPI+Nginx+Cloudflare](./doc/feature-api/cloudflare/cloudflare.md)

---

## Devops

- Deployment Environment

  - [Proxmox VE](./doc/feature-devops/proxmox/proxmox.md)
  - [Environment Setup](./doc/feature-devops/deploy_env/deploy_env.md)

- Services:
  - [NFS Service](./doc/feature-devops/nfs_server/nfs_server.md)
  - [Jenkins Service](./doc/feature-devops/jenkins/jenkins.md)
