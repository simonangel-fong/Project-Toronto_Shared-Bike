# Ansible

[Back](../../../README.md)

## Setup

### Define network

- Control node

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.10/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname control-host
sudo cat <<EOF >> /etc/hosts
192.168.128.10      control-host
127.0.0.1           control-host
EOF
```

- Managed node

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.100/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname managed-node
sudo cat <<EOF >> /etc/hosts
192.168.128.10      managed-node
127.0.0.1           managed-node
EOF
```

---

- Enable SSH

```sh
# control node
# generate an SSH key
ssh-keygen

# Copy the public key to managed node
ssh-copy-id aadmin@192.168.128.100

# test
ssh 'aadmin@192.168.128.100'
```

---

## Install Ansible on control node

```sh
# isntall
sudo dnf install ansible-core -y

# confirm
ansible --version
```

---

## Create your Ansible inventory

- Control node

```sh
# as admin
mkdir -pv ~/project/ansible/

# create Inventory
cat > ~/project/ansible/inventory.ini <<EOF
[rhel9]
192.168.128.100 ansible_ssh_user=aadmin
EOF

# Test the connection, ping as root
ansible rhel9 -i ./inventory.ini -m ping --user=aadmin
# 192.168.128.100 | SUCCESS => {
#     "ansible_facts": {
#         "discovered_interpreter_python": "/usr/bin/python3"
#     },
#     "changed": false,
#     "ping": "pong"
# }
```

---

- Setup NFS server

- `nfs_server_setup.yml`

```sh
ansible-galaxy collection install ansible.posix

cat > ~/project/ansible/nfs_server_setup.yml<< EOF
---
- name: Configure NFS server on rhel9
  hosts: rhel9
  become: yes
  tasks:

    - name: Install NFS server packages
      dnf:
        name: nfs-utils
        state: present

    - name: Enable and start the NFS server
      systemd:
        name: nfs-server
        enabled: yes
        state: started

    - name: Create export directory
      file:
        path: /srv/nfs_share
        state: directory
        mode: '0777'
        owner: nobody
        group: nobody

    - name: Configure /etc/exports
      copy:
        dest: /etc/exports
        content: "/srv/nfs_share  *(rw,sync,no_root_squash,no_subtree_check)\n"
        owner: root
        group: root
        mode: '0644'

    - name: Export the shared directory
      command: exportfs -ra

    - name: Allow NFS through the firewall
      ansible.posix.firewalld:
        service: nfs
        state: enabled
        immediate: yes
        permanent: yes

    - name: Reload firewalld
      systemd:
        name: firewalld
        state: restarted
EOF
```

```sh
ansible-playbook nfs_server_setup.yml -i ./inventory.ini --user root --ask-become-pass
```
