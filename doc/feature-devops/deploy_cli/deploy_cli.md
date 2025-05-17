# Deployment: Application Deployment (Manual Command)

[Back](../../../README.md)

- [Deployment: Application Deployment (Manual Command)](#deployment-application-deployment-manual-command)
  - [Add Admin](#add-admin)
  - [Network](#network)
  - [Upload ini Shell Script and env files](#upload-ini-shell-script-and-env-files)
  - [Deploy Application](#deploy-application)
    - [Creating Directories](#creating-directories)
    - [Git Clone](#git-clone)
    - [Build Oracle DB](#build-oracle-db)
    - [ETL](#etl)
    - [Backup](#backup)
    - [Deploy Cloudflare](#deploy-cloudflare)
  - [Deploymen using custom shell script](#deploymen-using-custom-shell-script)
    - [1. Upload init script](#1-upload-init-script)
    - [2. Execute init script](#2-execute-init-script)
    - [3. Migrate conf and env files](#3-migrate-conf-and-env-files)
    - [4. Install docker](#4-install-docker)
    - [5. Startup oracledb container](#5-startup-oracledb-container)
      - [ETL](#etl-1)
      - [Backup](#backup-1)
    - [6. Startup All](#6-startup-all)
  - [Init \& migrate](#init--migrate)

---

## Add Admin

```sh
sudo useradd -m aadmin
sudo passwd aadmin
sudo usermod -aG wheel aadmin

# test
su - aadmin
sudo whoami
```


## Network

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens18 ipv4.address 192.168.100.100/24
sudo nmcli c modify ens18 ipv4.gateway 192.168.100.254
sudo nmcli c modify ens18 ipv4.dns 192.168.100.254,8.8.8.8
sudo nmcli c modify ens18 ipv4.method manual
sudo nmcli c up ens18

# configure hostname
sudo hostnamectl set-hostname app-node
echo '192.168.128.100      app-node' | sudo tee -a /etc/hosts
echo '127.0.0.1           app-node' | sudo tee -a /etc/hosts
```

---

## Upload ini Shell Script and env files

```sh
scp ./devops/shell/00_init_git.sh aadmin@192.168.128.100:~
```

- Execute init shell script

```sh
bash 00_init.sh
```

---

## Deploy Application

### Creating Directories

```sh
# Removing existing project directories...
sudo rm -rf "/project/github" "/project/config" "/project/env"

# Creating project directories...
sudo mkdir -pv "/project/github" "/project/config" "/project/env" "/project/data" "/project/export" "/project/oradata" "/project/orabackup"

# change owner
sudo chown jenkins:jenkins -Rv /project/
```

### Git Clone

```sh
sudo rm -rf /project/github
sudo mkdir -pv /project/github

# clone the devops branch
cd /project/github
git config --global --add safe.directory /project/github
sudo git clone --branch feature-devops https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git /project/github

# change owner
sudo chown jenkins:jenkins -Rv /project/github
# change permission
sudo find /project/github -type f -name "*.sh" -exec chmod 755 {} +


sudo chmod 0777 -v /project/orabackup
sudo chmod 0777 -v /project/export
sudo chmod 0777 -v /project/oradata
sudo chmod 0777 -Rv /project/data
```

---

### Build Oracle DB

```sh
# Remove and clone the latest github
sudo rm -rf /project/github
sudo mkdir -pv /project/github

# set git
sudo git config --global --add safe.directory /project/github
# clone code
sudo git clone --branch feature-devops https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git /project/github


sudo chown jenkins:jenkins -Rv /project/github
# set sh file permission
sudo find /project/github -type f -name "*.sh" -exec chmod 755 -v {} +

sudo docker compose -f /project/github/oracledb/compose.oracledb.prod.yaml up --build -d

# test
docker ps
docker exec -it oracle19cDB bash

# debug
docker logs -f oracle19cDB

# clean up
docker compose -f /project/github/oracledb/compose.oracledb.prod.yaml down
docker volume rm toronto-shared-bike_oracledata
```

---

### ETL

- Migrate

```sh
scp -r -o ProxyJump=root@192.168.1.80 ./project/data aadmin@192.168.100.100:/project
```

```sh
sudo chown jenkins:jenkins -Rv /project/data
sudo chmod 0777 -Rv /project/data
sudo find /project/data -type f -name *.log -exec rm -v {} +;
sudo find /project/data -type f -name *.bad -exec rm -v {} +;
docker exec -it oracle19cDB /project/scripts/etl/single_year_etl_job.sh 2019
# refresh mv
docker exec -it oracle19cDB /project/scripts/mv/mv_refresh.sh
```

---

### Backup

```sh
docker exec -it oracle19cDB /project/scripts/backup/rman_create_backup_with_tag.sh YEAR_2019
```

---

### Deploy Cloudflare

```sh
docker compose -f /project/github/cloudflare/compose.cloudflare.prod.yaml up --build -d

docker compose -f /project/github/cloudflare/compose.cloudflare.prod.yaml down
```

---

## Deploymen using custom shell script

### 1. Upload init script

```sh
# migrate init script
scp ./devops/shell/00_init_git.sh aadmin@192.168.128.100:~
```

---

### 2. Execute init script

- Execute init script to create dir, install git, and clone git code.

```sh
# execute init script
su - -c "bash /home/aadmin/00_init_git.sh"
```

---

### 3. Migrate conf and env files

```sh
# migrate conf, env files
scp -r ./project/config ./project/env/ aadmin@192.168.128.100:/project/
```

---

### 4. Install docker

```sh
# install docker
su - -c "bash /project/github/devops/shell/01_install_docker.sh"
```

### 5. Startup oracledb container

```sh
# startup oracledb
# as aadmin
bash /project/github/devops/shell/02_startup_oracledb.sh
```

---

#### ETL

- Migrate source data

```sh
# migrate init script
scp -r ./project/data/ aadmin@192.168.128.100:/project/
```

- ETL job

```sh
# backup
docker exec -it oracle19cDB /project/scripts/backup/rman_create_backup_with_tag.sh YEAR_2019
# etl
docker exec -it oracle19cDB /project/scripts/etl/single_year_etl_job.sh 2019

# bulk etl
docker exec -it oracle19cDB /project/scripts/etl/multiple_year_etl_job.sh 2020 2023

# refresh mv
docker exec -it oracle19cDB /project/scripts/mv/mv_refresh.sh
```

---

#### Backup

```sh
docker exec -it oracle19cDB /project/scripts/backup/rman_create_backup_with_tag.sh YEAR_2019
```

---

### 6. Startup All

```sh
docker compose -f /project/github/cloudflare/compose.cloudflare.prod.yaml up --build -d
docker compose -f /project/github/cloudflare/compose.cloudflare.prod.yaml down
```

---

## Init & migrate

```sh
mkdir -pv /home/aadmin/project
# # set gid
# sudo chown :jenkins -R /home/aadmin/project


scp -r ./devops/shell/00_init.sh ./project/config ./project/env aadmin@192.168.128.100:~/project


sudo cp /home/aadmin/project/config/* /project/config


docker inspect -f {{.State.Health.Status}} oracle19cDB


# check health
echo 'SELECT 1 FROM dual;' | sqlplus -s sys/$ORACLE_PWD@localhost:1521/toronto_shared_bike as sysdba


sqlplus -s sys/'SecurePassword!234'@localhost:1521/toronto_shared_bike as sysdba
```
