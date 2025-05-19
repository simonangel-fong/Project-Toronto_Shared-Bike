# Deployment using Jenkins

[Back](../../../README.md)

- [Deployment using Jenkins](#deployment-using-jenkins)
  - [Initialize](#initialize)
  - [Configure Jenkins](#configure-jenkins)
  - [ETL job](#etl-job)

---

## Initialize

- Migrate init shell script and config files

```sh
scp -r -o ProxyJump=root@192.168.1.80 ./devops/shell/00_init.sh ./project/config ./project/env aadmin@192.168.100.100:~
```

- Execute init shell script

```sh
# run as aadmin
bash /home/aadmin/00_init.sh
```

---

## Configure Jenkins

- Login
- Install plugins
- Add jenkins to sudo

```sh
sudo visudo

jenkins ALL=(ALL) NOPASSWD: ALL
```

---

- Github:
  - https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git
- branch
  - feature-devops

| Pipeline              | File                                      | Desc                    |
| --------------------- | ----------------------------------------- | ----------------------- |
| `00_devops_init`      | `devops/Jenkinsfile.devops.init`          | Initialized the project |
| `00_devops_cleanup`   | `devops/Jenkinsfile.devops.cleanup`       | Clean up the project    |
| `01_oracledb_start`   | `oracledb/Jenkinsfile.oracledb.start`     | Start oracledb          |
| `01_oracledb_stop`    | `oracledb/Jenkinsfile.oracledb.stop`      | Stop oracledb           |
| `01_oracledb_etl_mv`  | `oracledb/Jenkinsfile.oracledb.etl`       | ETL oracledb            |
| `01_oracledb_backup`  | `oracledb/Jenkinsfile.oracledb.backup`    | Backup oracledb         |
| `02_cloudflare_start` | `cloudflare/Jenkinsfile.cloudflare.start` | Start Cloudflare        |
| `02_cloudflare_stop`  | `cloudflare/Jenkinsfile.cloudflare.stop`  | Stop Cloudflare         |

---

## ETL job

- Migrate data

```sh
scp -r -o ProxyJump=root@192.168.1.80 ./project/data root@192.168.100.100:/project
```

| Pipeline       | File                                | Desc         |
| -------------- | ----------------------------------- | ------------ |
| `oracledb-etl` | `oracledb/Jenkinsfile.oracledb.etl` | ETL oracledb |
