# NFS Server

### Server

- Monitor node

```sh
sudo dnf install nfs-utils -y
sudo systemctl enable --now nfs-server rpcbind

sudo systemctl status nfs-server

```

- Create and Configure the Export Directory

```sh
sudo mkdir -vp /srv/project/data
sudo mkdir -vp /srv/project/config
sudo chown nobody:nobody -R /srv/project
sudo chmod 755 /srv/project

echo "/srv/project 192.168.128.0/24(rw,sync,no_root_squash)" | sudo tee -a /etc/exports

# Export the Share
sudo exportfs -rav

```

- Adjust the Firewall

```sh
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload

sudo exportfs -v
```

---

## autofs

```sh
cd ~/project/ansible

cat > inventory.ini <<EOF
[application_node]
192.168.128.100 ansible_ssh_user=aadmin
EOF

cat > nfs_client_mount.yml <<EOF
---
- name: Configure autofs to mount NFS share at /project
  hosts: application_node
  become: true

  vars:
    nfs_server: 192.168.128.10
    export_path: /srv/project
    mount_point: /project
    autofs_map_dir: /etc/auto.master.d
    autofs_map_file: project.nfs

  tasks:
    - name: Install autofs
      package:
        name: autofs
        state: present

    - name: Create NFS mount point
      file:
        path: "{{ mount_point }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Ensure entry in /etc/auto.master for direct map
      lineinfile:
        path: /etc/auto.master
        regexp: "^/-"
        line: "/-  {{ autofs_map_dir }}/{{ autofs_map_file }}"
        state: present

    - name: Ensure auto.master.d directory exists
      file:
        path: "{{ autofs_map_dir }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Create direct map file for /project
      copy:
        dest: "{{ autofs_map_dir }}/{{ autofs_map_file }}"
        content: |
          {{ mount_point }} {{ nfs_server }}:{{ export_path }}
        owner: root
        group: root
        mode: '0644'

    - name: Reload autofs service
      service:
        name: autofs
        state: reloaded
        enabled: true

    - name: Restart autofs service
      service:
        name: autofs
        state: restarted
        enabled: true

    - name: Verify mount by accessing directory
      command: ls -l {{ mount_point }}
      register: mount_output
      changed_when: false

    - name: Show mounted directory contents
      debug:
        var: mount_output.stdout_lines
EOF

ansible-playbook -i inventory.ini nfs_client_mount.yml -u aadmin --ask-become-pass
```

- Confirm

```sh
# on monitor node
sudo cat > /srv/project/test.txt <<EOF
this is a test
EOF

# connect to a app node
ssh aadmin@192.168.128.100
ll /project
```
