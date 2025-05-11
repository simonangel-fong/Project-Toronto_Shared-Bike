# Deployment: Application Deployment using CLI

[Back](../../../README.md)

- [Deployment: Application Deployment using CLI](#deployment-application-deployment-using-cli)
  - [Central Configuration Repo](#central-configuration-repo)
  - [Application Deployment on App Node](#application-deployment-on-app-node)
    - [Install git and Clone codes](#install-git-and-clone-codes)
    - [Install Docker](#install-docker)
  - [Run Oracle DB](#run-oracle-db)
    - [Deploy Oracle DB](#deploy-oracle-db)

---

## Central Configuration Repo

- Create Dir

```sh
# monitor node
sudo mkdir -pv /project_repo/config # config
sudo mkdir -pv /project_repo/env # env
sudo mkdir -pv /project_repo/data # source data
sudo mkdir -pv /project_repo/export # export data
sudo mkdir -pv /project_repo/orabackup  # backup
# sudo mkdir -pv /project_repo/github # github code
```

- Migrate Files

```sh
# migrate config files
scp ./project/config/* root@192.168.128.10:/project_repo/config

# migrate env files
scp -r ./project/env/* root@192.168.128.10:/project_repo/env

# migrate source data
scp -r ./project/data/* root@192.168.128.10:/project_repo/data

# # migrate db backup
# scp -r ./project/orabackup/* root@192.168.128.10:/project_repo/orabackup
```

---

## Application Deployment on App Node

### Install git and Clone codes

- CLI Command

```sh
sudo dnf install -y git

mkdir -pv ~/github
git config --global --add safe.directory ~/github

# clone the devops branch
git clone --branch feature-devops https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git ~/github
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
docker run hello-world
```

---

## Run Oracle DB

```sh

cd ~/github
# pull the latest version
git pull

# Create container
docker compose -f ~/github/oracledb/compose.oracledb.prod.yaml up --build -d

# test
docker ps
docker exec -it oracle19cDB bash

# debut
docker logs oracle19cDB
```

---

- Command

```sh
ansible-playbook -i inventory.ini install_docker.yml --ask-become
```

---

### Deploy Oracle DB

```sh
docker compose -f /project/github/oracledb/compose.oracledb.prod.yaml up --build -d


```
