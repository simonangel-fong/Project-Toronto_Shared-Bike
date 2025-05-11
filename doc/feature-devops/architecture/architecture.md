# Deployment: Architecture

[Back](../../../README.md)

- [Deployment: Architecture](#deployment-architecture)
  - [Architecture](#architecture)
  - [Initial Setup](#initial-setup)
    - [Monitor Node](#monitor-node)
    - [App Node](#app-node)
  - [Ansible Setup](#ansible-setup)
    - [Create Ansible SSH](#create-ansible-ssh)
    - [Configure Inventory](#configure-inventory)

---

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

## Initial Setup

### Monitor Node

- Network

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.10/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 192.168.128.2,8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname monitor-host
sudo cat <<EOF >> /etc/hosts
192.168.128.10      monitor-host
127.0.0.1           monitor-host
EOF
```

---

### App Node

- Network

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.100/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 192.168.128.2,8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname application-node
sudo cat <<EOF >> /etc/hosts
192.168.128.100      application-node
127.0.0.1           application-node
EOF
```

---


## Ansible Setup

### Create Ansible SSH

```sh
# control node
ssh-keygen

# copy public key to app node
ssh-copy-id aadmin@192.168.128.100

# confirm without pwd
ssh aadmin@192.168.128.100
```

---

### Configure Inventory

```sh
# as admin
mkdir -pv ~/project/ansible/

# create Inventory
cat > ~/project/ansible/inventory.ini <<EOF
[app_node]
192.168.128.100 ansible_ssh_user=aadmin
EOF

# Test the connection, ping as root
ansible app_node -i ~/project/ansible/inventory.ini -m ping --user=aadmin
# 192.168.128.100 | SUCCESS => {
#     "ansible_facts": {
#         "discovered_interpreter_python": "/usr/bin/python3"
#     },
#     "changed": false,
#     "ping": "pong"
# }
```
