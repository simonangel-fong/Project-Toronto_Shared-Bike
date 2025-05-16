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
scp -r ./devops/shell/00_init.sh ./project/config ./project/env aadmin@192.168.128.100:~
```

- Execute init shell script

```sh
# run as root
sudo bash /home/aadmin/00_init.sh
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
| `00-devops-init`      | `devops/Jenkinsfile.devops.init`          | Initialized the project |
| `00-devops-cleanup`   | `devops/Jenkinsfile.devops.cleanup`       | Clean up the project    |
| `01-oracledb-start`   | `oracledb/Jenkinsfile.oracledb.start`     | Start oracledb          |
| `01-oracledb-stop`    | `oracledb/Jenkinsfile.oracledb.stop`      | Stop oracledb           |
| `01-oracledb-etl-mv`  | `oracledb/Jenkinsfile.oracledb.etl`       | ETL oracledb            |
| `01-oracledb-backup`  | `oracledb/Jenkinsfile.oracledb.backup`             | Backup oracledb         |
| `02-cloudflare-start` | `cloudflare/Jenkinsfile.cloudflare.start` | Start Cloudflare        |
| `02-cloudflare-stop`  | `cloudflare/Jenkinsfile.cloudflare.stop`  | Stop Cloudflare         |

---

## ETL job

- Migrate data

```sh
scp -r ./project/data root@192.168.128.100:/project
```

| Pipeline       | File                                | Desc         |
| -------------- | ----------------------------------- | ------------ |
| `oracledb-etl` | `oracledb/Jenkinsfile.oracledb.etl` | ETL oracledb |
