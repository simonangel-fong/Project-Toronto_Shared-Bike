# Deployment: Application Deployment using CLI

[Back](../../../README.md)

- [Deployment: Application Deployment using CLI](#deployment-application-deployment-using-cli)
    - [Network](#network)
    - [Install git and Clone codes](#install-git-and-clone-codes)
  - [App Node Initial Setup](#app-node-initial-setup)
  - [Configuration Repo](#configuration-repo)
  - [Application Deployment](#application-deployment)
    - [Install Docker](#install-docker)
  - [Run Oracle DB](#run-oracle-db)
    - [Deploy Cloudflare](#deploy-cloudflare)
    - [ETL](#etl)

---

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

### Install git and Clone codes

- CLI Command

```sh
sudo dnf install -y git

sudo mkdir -pv /project/github

# change owner
sudo chown aadmin:aadmin -R /project/github
git config --global --add safe.directory /project/github

# clone the devops branch
git clone --branch feature-devops https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git /project/github

# change permission
find /project/github -type f -name "*.sh" -exec chmod 755 {} \;

sudo bash /project/github/
```

## App Node Initial Setup

## Configuration Repo

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
find /project -type d -exec chmod 755 {} +
# ensure files within the subdir to be read-only
find /project -type f -exec chmod 444 {} +

# enable backup dir to be written for bakcup and export data
chmod 0777 /project/orabackup
chmod 0777 /project/export
```

- Migrate Files

```sh
# migrate config files
scp -r ./project/config aadmin@192.168.128.100:/project/
scp -r ./project/env/ aadmin@192.168.128.100:/project/
scp -r ./project/data/ aadmin@192.168.128.100:/project/

scp -r ./project/config ./project/env/ ./project/data/ aadmin@192.168.128.100:/project/
```

---

## Application Deployment

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

## Run Oracle DB

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

### Deploy Cloudflare

```sh
docker compose -f ~/github/cloudflare/compose.cloudflare.prod.yaml up --build -d

docker compose -f ~/github/cloudflare/compose.cloudflare.prod.yaml down
```

---

### ETL

```sh
docker exec -it oracle19cDB /project/scripts/etl/single_year_etl_job.sh 2019
```
