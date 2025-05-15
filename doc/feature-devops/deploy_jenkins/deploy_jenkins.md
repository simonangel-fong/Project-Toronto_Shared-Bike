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

---

- Github:
  - https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git
- branch
  - feature-devops

| Pipeline           | File                                      | Desc                    |
| ------------------ | ----------------------------------------- | ----------------------- |
| `devops-init`      | `devops/Jenkinsfile.devops.init`          | Initialized the project |
| `oracledb-start`   | `oracledb/Jenkinsfile.oracledb.start`     | Start oracledb          |
| `oracledb-stop`    | `oracledb/Jenkinsfile.oracledb.stop`      | Stop oracledb           |
| `cloudflare-start` | `cloudflare/Jenkinsfile.cloudflare.start` | Start Cloudflare        |
| `cloudflare-stop`  | `cloudflare/Jenkinsfile.cloudflare.stop`  | Stop Cloudflare         |

---

## ETL job

- Migrate data

```sh
scp -r ./project/data root@192.168.128.100:/project
```

| Pipeline       | File                                | Desc         |
| -------------- | ----------------------------------- | ------------ |
| `oracledb-etl` | `oracledb/Jenkinsfile.oracledb.etl` | ETL oracledb |
