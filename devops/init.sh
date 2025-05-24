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

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

ORACLE_COMPOSE_FILE="${GITHUB_DIR}/oracledb/compose.oracledb.prod.yaml"
ORACLE_CON="oracle19cDB"

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

echo
echo "========================================================"
echo "Installing packages: git"
echo "========================================================"
echo

sudo dnf install -y git

echo
echo "========================================================"
echo "Installing Docker packages"
echo "========================================================"
echo

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

echo
echo "========================================================"
echo "Granting docker permission"
echo "========================================================"
echo

# set permission to run docker
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock

# add jenkins and aadmin to docker group
# sudo usermod -aG docker jenkins
sudo usermod -aG docker $APP_ADMIN

# as aadmin
# confirm as aadmin
echo "Current user as: $APP_ADMIN"
su - $APP_ADMIN -c "docker run hello-world"

echo
echo "========================================================"
echo "Removing existing project directories..."
echo "========================================================"
echo

sudo rm -rf "${BASE_DIR}"

echo
echo "========================================================"
echo "Creating project directories..."
echo "========================================================"
echo

sudo mkdir -pv "${GITHUB_DIR}" "${CONFIG_DIR}" "${SOURCE_DIR}" "${DPUMP_DIR}" "${ORADATA_DIR}" "${ORBACKUP_DIR}"

echo
echo "========================================================"
echo "Copy conf and env file"
echo "========================================================"
echo

sudo cp -r /root/config/ ${BASE_DIR}
# confirm
ls $CONFIG_DIR

echo
echo "========================================================"
echo "Cloning GitHub repository..."
echo "========================================================"
echo

sudo rm -rf $GITHUB_DIR
sudo mkdir -pv $GITHUB_DIR

sudo git config --global --add safe.directory "${GITHUB_DIR}"
sudo git clone --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${GITHUB_DIR}"

sudo chown "${APP_ADMIN}":"${APP_GROUP}" -Rv "${BASE_DIR}"

# Set shell script permissions
sudo find "${GITHUB_DIR}" -type f -name "*.sh" -exec chmod -v 755 {} +

# Set permissions
find "${BASE_DIR}" -type d -exec chmod -v 755 {} +
find "${BASE_DIR}" -type f -name "*.conf" -exec chmod -v 666 {} +
find "${BASE_DIR}" -type f -name "*.env" -exec chmod -v 666 {} +

sudo chmod 0777 -v "${DPUMP_DIR}"
sudo chmod 0777 -v "${ORADATA_DIR}"
sudo chmod 0777 -v "${ORBACKUP_DIR}"

echo
echo "========================================================"
echo "Starting up oracle container..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${ORACLE_COMPOSE_FILE} up --build -d"

echo
echo "========================================================"
echo "✅ Project setup completed successfully!"
echo "========================================================"
echo

# echo
# echo "========================================================"
# echo "Installing Jenkins packages"
# echo "========================================================"
# echo

# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
# sudo yum upgrade -y
# # Add required dependencies for the jenkins package
# sudo yum install -y fontconfig java-17-openjdk
# sudo yum install -y jenkins

# # sudo update-alternatives --config java
# sudo systemctl daemon-reload

# sudo systemctl enable --now jenkins

# sudo firewall-cmd --add-port=8080/tcp --permanent
# sudo firewall-cmd --reload

# echo
# echo "========================================================"
# echo "Jenkins credential"
# echo "========================================================"
# echo

# sudo cat /var/lib/jenkins/secrets/initialAdminPassword
