#!/bin/bash

# as root
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
HOST_NAME="app-node"
HOST_NIC="ens18"
HOST_IP="192.168.100.100"
HOST_SUBNET="24"
HOST_GATEWAY="192.168.100.254"
HOST_DNS="192.168.100.254,8.8.8.8"

APP_ADMIN="aadmin"
APP_GROUP="appgroup"

BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"

SOURCE_DIR="${BASE_DIR}/source"
DPUMP_DIR="${BASE_DIR}/dpump"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"

APP_ADMIN="aadmin"
APP_GROUP="appgroup"

echo
echo "========================================================"
echo "Configuring Network"
echo "========================================================"
echo

# setup network
sudo nmcli c modify $HOST_NIC ipv4.address $HOST_IP/$HOST_SUBNET
sudo nmcli c modify $HOST_NIC ipv4.gateway $HOST_GATEWAY
sudo nmcli c modify $HOST_NIC ipv4.dns $HOST_DNS
sudo nmcli c modify $HOST_NIC ipv4.method manual
sudo nmcli c down $HOST_NIC && sudo nmcli c up $HOST_NIC

echo
echo "========================================================"
echo "Configuring hostname"
echo "========================================================"
echo

# configure hostname
sudo hostnamectl set-hostname $HOST_NAME
echo "${HOST_IP}      ${HOST_NAME}" | sudo tee -a /etc/hosts
echo "127.0.0.1           ${HOST_NAME}" | sudo tee -a /etc/hosts

echo
echo "========================================================"
echo "Creating admin"
echo "========================================================"
echo

sudo useradd $APP_ADMIN
echo "Input password for ${APP_ADMIN}"
sudo passwd $APP_ADMIN

sudo groupadd $APP_GROUP
sudo usermod -aG $APP_GROUP $APP_ADMIN

echo
echo "========================================================"
echo "Upgrading packages"
echo "========================================================"
echo

sudo dnf upgrade -y
