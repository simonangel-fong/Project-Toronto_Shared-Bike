# Deployment: Application

[Back](../../../README.md)

- [Deployment: Application](#deployment-application)
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

# enable current user to run docker
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock

# confirm as current user
docker run hello-world
```

---

## Run Oracle DB

```sh
docker compose -f ~/github/oracledb/compose.oracledb.prod.yaml up --build -d
```


---

```sh
cat > ~/project/ansible/install_docker.yml <<EOF
---
- name: Install Docker on App Node
  hosts: application_node
  # need privilege
  become: yes
  tasks:
    - name: upgrade all packages
      dnf:
        name: "*"
        state: latest

    - name: remove the packages
      dnf:
        # package list
        name:
          - docker
          - docker-client
          - docker-client-latest
          - docker-common
          - docker-latest
          - docker-latest-logrotate
          - docker-logrotate
          - docker-engine
          - podman
          - runc
        state: absent

    - name: Install dnf plugins core
      dnf:
        name: dnf-plugins-core
        state: present

    - name: Add Docker repository
      get_url:
        url: https://download.docker.com/linux/rhel/docker-ce.repo
        dest: /etc/yum.repos.d/docker.repo

    - name: Install the latest version of Docker
      ansible.builtin.dnf:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: latest

    - name: Enable Docker service for dnf-automatic
      ansible.builtin.systemd_service:
        name: docker
        state: started
        enabled: true

    - name: Set permissions on Docker socket
      ansible.builtin.file:
        path: /var/run/docker.sock
        owner: root
        group: docker
        mode: '0666'

    - name: Run a hello-world container
      ansible.builtin.command: docker run hello-world
      register: docker_test_output

    - name: Print Docker hello-world output
      ansible.builtin.debug:
        var: docker_test_output.stdout
EOF
```

- Command

```sh
ansible-playbook -i inventory.ini install_docker.yml --ask-become
```

---

### Deploy Oracle DB

```sh
docker compose -f /project/github/oracledb/compose.oracledb.prod.yaml up --build -d


```
