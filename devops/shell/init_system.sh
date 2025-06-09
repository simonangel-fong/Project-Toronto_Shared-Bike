#!/bin/bash

# As root
set -e          # Exit on error
set -o pipefail # Propagate pipeline failures
set -u          # Treat unset variables as errors

# ========== Environment Variables ==========
HOST_NAME="app-node"
HOST_NIC="ens18"
HOST_IP="192.168.100.100"
HOST_SUBNET="24"
HOST_GATEWAY="192.168.100.254"
HOST_DNS="192.168.100.254,8.8.8.8"

APP_ADMIN="appadmin"
APP_GROUP="appgroup"

BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"

SOURCE_DIR="${BASE_DIR}/source"
DPUMP_DIR="${BASE_DIR}/dpump"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"

echo
echo "========================================================"
echo "Configuring Network"
echo "========================================================"
echo

# Setup network
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

# Configure hostname
sudo hostnamectl set-hostname $HOST_NAME
echo "${HOST_IP}    ${HOST_NAME}" | sudo tee -a /etc/hosts
echo "127.0.0.1     ${HOST_NAME}" | sudo tee -a /etc/hosts

echo
echo "========================================================"
echo "Upgrading packages"
echo "========================================================"
echo

sudo dnf upgrade -y

echo
echo "========================================================"
echo "Create a cron job to update at midnight"
echo "========================================================"
echo

# Automate update at midnight
echo "0 0 * * * /usr/bin/dnf upgrade -y" | sudo crontab -

# Confirm cron job
sudo crontab -l

echo
echo "========================================================"
echo "Creating admin"
echo "========================================================"
echo

# If user exists, delete and recreate
if id $APP_ADMIN &>/dev/null; then
    sudo userdel -r -f $APP_ADMIN
    echo "User '${APP_ADMIN}' deleted"
fi

sudo useradd $APP_ADMIN
echo "User '${APP_ADMIN}' is created"

echo "Input password for ${APP_ADMIN}"
sudo passwd $APP_ADMIN

if getent group $APP_GROUP &>/dev/null; then
    sudo groupdel ${APP_GROUP}
    echo "Group '${APP_GROUP}' deleted"
fi

sudo groupadd $APP_GROUP
sudo usermod -aG $APP_GROUP $APP_ADMIN

echo
echo "========================================================"
echo "Creating project directories..."
echo "========================================================"
echo

sudo mkdir -pv "${GITHUB_DIR}" "${CONFIG_DIR}" "${SOURCE_DIR}" "${DPUMP_DIR}" "${ORADATA_DIR}" "${ORBACKUP_DIR}"
# Set ownership for admin
sudo chown "${APP_ADMIN}":"${APP_GROUP}" -Rv "${BASE_DIR}"

echo
echo "========================================================"
echo "Installing packages: git"
echo "========================================================"
echo

sudo dnf install -y git

echo
echo "========================================================"
echo "Installing packages: Docker"
echo "========================================================"
echo

# Install Docker
sudo dnf remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

# Set permission to run Docker
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock

# Add admin to docker group
sudo usermod -aG docker $APP_ADMIN

echo
echo "========================================================"
echo "Installing packages: Jenkins"
echo "========================================================"
echo

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install -y fontconfig java-17-openjdk
sudo yum install -y jenkins

# Start Jenkins
sudo systemctl enable --now jenkins

# add jenkins to appgroup
sudo usermod -aG $APP_GROUP jenkins

# Open firewall for Jenkins
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

echo
echo "========================================================"
echo "✅ System initialization completed successfully!"
echo "========================================================"

# Provide Jenkins initial admin password
echo
echo "========================================================"
echo "Jenkins initial admin password"
echo "========================================================"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
