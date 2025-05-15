# Deployment: Application Deployment using CLI

[Back](../../../README.md)

- [Deployment: Application Deployment using CLI](#deployment-application-deployment-using-cli)
  - [Node Configuration](#node-configuration)
    - [Network](#network)
  - [Deployment - Manual way](#deployment---manual-way)
    - [Install git and Clone codes](#install-git-and-clone-codes)
    - [Create dir and Migrate config files](#create-dir-and-migrate-config-files)
    - [Install Docker](#install-docker)
    - [Run Oracle DB](#run-oracle-db)
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

## Node Configuration

### Network

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.100/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 192.168.128.2,8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname app-node
echo '192.168.128.100      app-node' | sudo tee -a /etc/hosts
echo '127.0.0.1           app-node' | sudo tee -a /etc/hosts
```

---

## Deployment - Manual way

### Install git and Clone codes

- CLI Command

```sh
# install git
sudo dnf install -y git

# create dir for github
sudo mkdir -pv /project/github

# change owner
sudo chown aadmin:aadmin -R /project/github

git config --global --add safe.directory /project/github
# clone the devops branch
git clone --branch feature-devops https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git /project/github

# change permission
find /project/github -type f -name "*.sh" -exec chmod 755 {} \;
```

---

### Create dir and Migrate config files

- Create Dir

```sh
# app node
# as root
sudo mkdir -pv /project/config # config
sudo mkdir -pv /project/env # env
sudo mkdir -pv /project/data # source data
sudo mkdir -pv /project/export # export data
sudo mkdir -pv /project/oradata # persist data
sudo mkdir -pv /project/orabackup  # backup

sudo chown aadmin:aadmin -R /project
# ensure sub dir can be access
find /project -type d -exec chmod 755 {} \;
# ensure files within the subdir to be read-only
find /project -type f --exec chmod 444 {} \;



# enable
chmod 0777 /project/orabackup
chmod 0777 /project/export
chmod 0777 /project/oradata
chmod 0777 -r /project/data
```

- Migrate Files

```sh
# migrate config and env files
scp -r ./project/config ./project/env/ ./project/data/ aadmin@192.168.128.100:/project/

# migrate source data
scp -r ./project/data/ aadmin@192.168.128.100:/project/
```

---

### Install Docker

- Install Docker

```sh
sudo dnf remove -y docker \
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

# as common user
# enable current user to run docker
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock

# as common user
# confirm as current user
docker run hello-world --user $USER
```

---

### Run Oracle DB

```sh

cd /project/github
# pull the latest version
git pull

# Create container
docker compose -f /project/github/oracledb/compose.oracledb.prod.yaml up --build -d && docker exec -it -u root:root oracle19cDB bash /project/scripts/init/init.sh

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

```sh
docker exec -it oracle19cDB /project/scripts/etl/single_year_etl_job.sh 2019
```

---

### Backup

```sh
docker exec -it oracle19cDB /project/scripts/backup/rman_create_backup_with_tag.sh YEAR_2019
```

---

### Deploy Cloudflare

```sh
docker compose -f ~/github/cloudflare/compose.cloudflare.prod.yaml up --build -d

docker compose -f ~/github/cloudflare/compose.cloudflare.prod.yaml down
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
# set gid
sudo chown :jenkins -R /home/aadmin/project


scp ./devops/shell/00_init.sh ./project/config ./project/env aadmin@192.168.128.100:~/project


sudo cp /home/aadmin/project/config/* /project/config
```