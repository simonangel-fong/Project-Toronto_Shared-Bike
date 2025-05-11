## Architecture

- Monitor node

  - ip: 192.168.128.10/24
  - gateway: 192.168.128.2/24
  - dns: 8.8.8.8
  - OS: RHEL 9.3
  - Tool:
    - Jenkins
    - Ansible
  - Association:
    - create Ansible control with App node.

- App node
  - ip: 192.168.128.100/24
  - gateway: 192.168.128.2/24
  - dns: 8.8.8.8
  - OS: RHEL 9.3
  - Tools:
    - Docker
  - Association:
    - Control by Monitor node via ansible.

---

## Create Ansible SSH

```sh
# control node
ssh-keygen

# copy public key to app node
ssh-copy-id aadmin@192.168.128.100

# confirm without pwd
ssh aadmin@192.168.128.100
```

---

## Inventory

```sh
# as admin
mkdir -pv ~/project/ansible/

# create Inventory
cat > ~/project/ansible/inventory.ini <<EOF
[application_node]
192.168.128.100 ansible_ssh_user=aadmin
EOF

# Test the connection, ping as root
ansible application_node -i ~/project/ansible/inventory.ini -m ping --user=aadmin
# 192.168.128.100 | SUCCESS => {
#     "ansible_facts": {
#         "discovered_interpreter_python": "/usr/bin/python3"
#     },
#     "changed": false,
#     "ping": "pong"
# }
```

---

## Install Docker on App Node via Ansible

- `install_docker.yml`

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

## Deploy

```sh
dnf install -y git

# monitor node
mkdir -pv /project/data # source data
mkdir -pv /project/export # export data
mkdir -pv /project/orabackup  # backup 
mkdir -pv /project/github # github code
mkdir -pv /project/config # config
mkdir -pv /project/env # env

# application node

# mount nfs

# download code
git clone https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git /project/github
```
