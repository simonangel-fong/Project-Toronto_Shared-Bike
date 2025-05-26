# Deployment: Application Deployment (Manual Command)

[Back](../../../README.md)

- [Deployment: Application Deployment (Manual Command)](#deployment-application-deployment-manual-command)
  - [Configure App Node](#configure-app-node)
    - [Add Admin](#add-admin)
    - [Network](#network)
    - [Install Package](#install-package)
    - [Setup Jenkins](#setup-jenkins)
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
  - [New Manual](#new-manual)

---

## Configure App Node

### Add Admin

```sh
sudo useradd -m aadmin
sudo passwd aadmin
sudo usermod -aG wheel aadmin

# test
su - aadmin
sudo whoami
```

---

### Network

```sh
# setup network
sudo nmcli c down ens18
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

### Install Package

```sh
sudo dnf upgrade -y

# install git
sudo dnf install -y git

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
# Add required dependencies for the jenkins package
sudo yum install -y fontconfig java-17-openjdk
sudo yum install -y jenkins

# sudo update-alternatives --config java
sudo systemctl daemon-reload

sudo systemctl enable --now jenkins

sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

# Install Docker
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

# set permission to run docker
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock

sudo usermod -aG docker jenkins
sudo usermod -aG docker aadmin

# test
su - aadmin
docker run hello-world

# create dir
sudo mkdir -pv /project
sudo chown jenkins:jenkins -Rv /project
```

---

### Setup Jenkins

```sh
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## Deploy Application

### Creating Directories

```sh



sudo mkdir -pv /project/github
sudo mkdir -pv /project/config
sudo mkdir -pv ${ENV_DIR}

sudo mkdir -pv ${DATA_DIR}
sudo mkdir -pv ${EXPORT_DIR}
sudo mkdir -pv ${ORADATA_DIR}
sudo mkdir -pv ${ORBACKUP_DIR}


GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"
ENV_DIR="${BASE_DIR}/env"

DATA_DIR="${BASE_DIR}/data"
EXPORT_DIR="${BASE_DIR}/export"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"

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
scp -r -o ProxyJump=root@192.168.1.80 ./project/config root@192.168.100.100:~
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

---

## New Manual

- Migrate

```sh
# test
scp -r ./devops/shell ./project/config ./project/dpump root@192.168.128.100:~

scp -r -i "Argus_Lab.pem" C:\Users\simon\OneDrive\Tech\Github\Project-Toronto_Shared-Bike\devops\shell ec2-user@ec2-3-95-163-80.compute-1.amazonaws.com:~

scp -r -i "Argus_Lab.pem" C:\Users\simon\OneDrive\Tech\Github\Project-Toronto_Shared-Bike\project\config ec2-user@ec2-3-95-163-80.compute-1.amazonaws.com:~

scp -r -i "Argus_Lab.pem" C:\Users\simon\OneDrive\Tech\Github\Project-Toronto_Shared-Bike\project\dpump ec2-user@ec2-3-95-163-80.compute-1.amazonaws.com:~

project

# prod
scp -r -o ProxyJump=root@192.168.1.80 ./devops/shell ./project/config ./project/dpump root@192.168.100.100:~
```

- Deploy

```sh
bash ~/shell/00_pre_deploy.sh

bash ~/shell/01_deploy.sh
```