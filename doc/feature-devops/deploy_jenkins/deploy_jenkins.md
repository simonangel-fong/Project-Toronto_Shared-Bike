# Deployment using Jenkins

[Back](../../../README.md)

- [Deployment using Jenkins](#deployment-using-jenkins)
  - [Initialize](#initialize)
  - [Configure Jenkins](#configure-jenkins)

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

| Pipeline           | File                                      | Desc                    |
| ------------------ | ----------------------------------------- | ----------------------- |
| `devops-init`      | `devops/Jenkinsfile.devops.init`          | Initialized the project |
| `oracledb-start`   | `oracledb/Jenkinsfile.oracledb.start`     | Start oracledb          |
| `oracledb-stop`    | `oracledb/Jenkinsfile.oracledb.stop`      | Stop oracledb           |
| `oracledb-etl`     | `oracledb/Jenkinsfile.oracledb.etl`       | ETL oracledb            |
| `cloudflare-start` | `cloudflare/Jenkinsfile.cloudflare.start` | Start Cloudflare        |
| `cloudflare-stop`  | `cloudflare/Jenkinsfile.cloudflare.stop`  | Stop Cloudflare         |
