# Ansible

[Back](../../../README.md)

- [Ansible](#ansible)
  - [Setup Ansible](#setup-ansible)
    - [Define network](#define-network)
    - [Install Ansible Package](#install-ansible-package)
    - [Create and Test Ansible inventory](#create-and-test-ansible-inventory)

[Back](../../../README.md)

## Setup Ansible

### Define network

- Monitor node

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.10/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname monitor-host
sudo cat <<EOF >> /etc/hosts
192.168.128.10      monitor-host
127.0.0.1           monitor-host
EOF
```

- Application node

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.100/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname application-node
sudo cat <<EOF >> /etc/hosts
192.168.128.10      application-node
127.0.0.1           application-node
EOF
```

---

- Enable SSH

```sh
# Monitor node
# generate an SSH key
ssh-keygen

# Copy the public key to managed node
ssh-copy-id aadmin@192.168.128.100

# test
ssh aadmin@192.168.128.100
```

---

### Install Ansible Package

```sh
# isntall
sudo dnf install ansible-core -y

# confirm
ansible --version
```

---

### Create and Test Ansible inventory

- Monitor node

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
