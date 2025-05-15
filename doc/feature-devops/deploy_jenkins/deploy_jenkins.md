# Deployment using Jenkins

[Back](../../../README.md)

- [Deployment using Jenkins](#deployment-using-jenkins)
  - [Initialize](#initialize)
  - [Configure Jenkins](#configure-jenkins)
    - [Create Oracle DB pipeline](#create-oracle-db-pipeline)

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

### Create Oracle DB pipeline

```sh

```