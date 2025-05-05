# Ansible

[Back](../../../README.md)

- [Ansible](#ansible)
  - [Setup Ansible](#setup-ansible)
    - [Install Ansible Package](#install-ansible-package)
    - [Create and Test Ansible inventory](#create-and-test-ansible-inventory)

[Back](../../../README.md)

## Setup Ansible

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
