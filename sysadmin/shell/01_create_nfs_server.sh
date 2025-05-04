#!/bin/bash

# Set up NFS Server on monitor server

sudo dnf install nfs-utils -y
sudo systemctl enable --now nfs-server rpcbind

# sudo systemctl status nfs-server

sudo mkdir -pv /srv/nfs_share
sudo chown nobody:nobody -R /srv/nfs_share
sudo chmod 755 -R /srv/nfs_share

echo "/srv/nfs_share 192.168.1.0/24(rw,sync,no_root_squash)" | sudo tee -a /etc/exports

# Export the Share
sudo exportfs -rav