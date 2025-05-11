# Deployment: Setup NFS Service

[Back](../../../README.md)

- [Deployment: Setup NFS Service](#deployment-setup-nfs-service)
  - [Setup NFS Server](#setup-nfs-server)
  - [Setup NFS Client](#setup-nfs-client)
    - [CLI Command](#cli-command)
    - [Using Ansible](#using-ansible)

---

## Setup NFS Server

- Monitor node

```sh
#!/bin/bash

# === Parameters ===
EXPORT_DIR="/project_repo"
ALLOWED_SUBNET="192.168.128.0/24"
EXPORT_OPTIONS="rw,sync,no_root_squash"

# === Install and Enable NFS Services ===
sudo dnf install -y nfs-utils
sudo systemctl enable --now nfs-server rpcbind

# Check service status
sudo systemctl status nfs-server

# === Create and Configure the Export Directory ===
sudo mkdir -pv "$EXPORT_DIR"
sudo chown nobody:nobody -R "$EXPORT_DIR"
sudo chmod 755 "$EXPORT_DIR"

# Add export entry
echo "$EXPORT_DIR $ALLOWED_SUBNET($EXPORT_OPTIONS)" | sudo tee -a /etc/exports

# Export the share
sudo exportfs -rav

# === Adjust the Firewall ===
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload

# Show exported shares
sudo exportfs -v
showmount -e localhost
```

---

## Setup NFS Client

### CLI Command

```sh
# app node
sudo dnf install -y nfs-utils autofs
sudo systemctl enable autofs --now

showmount -e 192.168.128.10

# create nfs mount point
sudo mkdir -pv /project
sudo chown aadmin:aadmin -R /project
sudo chmod 0755 -R /project

ll /project -d
# drwxr-xr-x. 2 aadmin aadmin 6 May 11 15:32 /project

# add entry to auto cf
echo "/-  /etc/auto.master.d/auto.project" | sudo tee -a /etc/auto.master
echo "/project -fstype=nfs,rw,sync 192.168.128.10:/project_repo" | sudo tee -a /etc/auto.master.d/auto.project

sudo systemctl reload autofs
sudo systemctl restart autofs

# confirm
ll /project
```

### Using Ansible

```sh
# monitor node
cat > ~/project/ansible/setup_nfs_client.yml <<EOF
---
- name: Configure NFS client and autofs on app node
  hosts: app_node
  become: yes
  vars:
    nfs_server_ip: "192.168.128.10"
    nfs_export_path: "/project_repo"
    mount_point: "/project"
    autofs_master_file: "/etc/auto.master"
    autofs_map_file: "/etc/auto.master.d/auto.project"
    mount_owner: "aadmin"
    mount_group: "aadmin"

  tasks:

    - name: Install NFS and autofs packages
      dnf:
        name:
          - nfs-utils
          - autofs
        state: present

    - name: Enable and start autofs service
      systemd:
        name: autofs
        enabled: yes
        state: started

    - name: Create NFS mount point directory
      file:
        path: /project
        state: directory
        owner: aadmin
        group: aadmin
        mode: '0755'

    - name: Add autofs master entry
      lineinfile:
        path: /etc/auto.master
        line: "/-  /etc/auto.master.d/auto.project"
        create: yes
        insertafter: EOF

    - name: Create autofs map for NFS mount
      copy:
        dest: /etc/auto.master.d/auto.project
        content: |
          /project -fstype=nfs,rw,sync 192.168.128.10:/project_repo
        owner: root
        group: root
        mode: '0644'

    - name: Reload autofs configuration
      ansible.builtin.systemd_service:
        name: autofs
        state: reloaded

    - name: Restart autofs service
      ansible.builtin.systemd_service:
        name: autofs
        state: restarted

    - name: Check if /project is mounted
      command: ls -l /project
      register: mount_check
      ignore_errors: yes

    - name: Print mount result
      debug:
        var: mount_check.stdout_lines
EOF

ansible-playbook ~/project/ansible/setup_nfs_client.yml -i ~/project/ansible/inventory.ini --ask-become
```
