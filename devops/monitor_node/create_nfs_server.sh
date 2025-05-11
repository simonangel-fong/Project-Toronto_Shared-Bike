#!/bin/bash

# === Parameters ===
EXPORT_DIR="/project"
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