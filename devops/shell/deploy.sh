#!/bin/bash

# as root
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
APP_ADMIN="aadmin"
APP_GROUP="appgroup"

BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"

SOURCE_DIR="${BASE_DIR}/source"
DPUMP_DIR="${BASE_DIR}/dpump"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

ORACLE_COMPOSE_FILE="${GITHUB_DIR}/oracledb/compose.oracledb.prod.yaml"
CLOUDFLARE_COMPOSE_FILE="${GITHUB_DIR}/cloudflare/compose.cloudflare.prod.yaml"

echo
echo "========================================================"
echo "Upgrading packages"
echo "========================================================"
echo

sudo dnf upgrade -y

echo
echo "========================================================"
echo "Creating admin"
echo "========================================================"
echo

# if exits
if id "aadmin" &>/dev/null; then
    sudo userdel -r -f aadmin
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
# su - $APP_ADMIN -c "docker run hello-world"

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
echo "Copy import data"
echo "========================================================"
echo

sudo cp -rv ~/dpump/ ${BASE_DIR}
# confirm
ls $DPUMP_DIR

echo
echo "========================================================"
echo "Copy conf and env file"
echo "========================================================"
echo

sudo cp -rv ~/config/ ${BASE_DIR}
# confirm
ls $CONFIG_DIR

echo
echo "========================================================"
echo "Cloning GitHub repository..."
echo "========================================================"
echo

cd ~
sudo rm -rf $GITHUB_DIR
sudo mkdir -pv $GITHUB_DIR

# clone github
sudo git clone --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${GITHUB_DIR}"

# set ownership for aadmin
sudo chown "${APP_ADMIN}":"${APP_GROUP}" -Rv "${BASE_DIR}"

# set ownership for oracle
sudo chown 54321:54321 -Rv "${ORADATA_DIR}"
sudo chown 54321:54321 -Rv "${GITHUB_DIR}/oracledb/scripts"
sudo chown 54321:54321 -Rv "${DPUMP_DIR}"
sudo chown 54321:54321 -Rv "${ORBACKUP_DIR}"

# Set shell script permissions
sudo find "${GITHUB_DIR}" -type f -name "*.sh" -exec chmod -v 755 {} +

# Set permissions
sudo find "${BASE_DIR}" -type d -exec sudo chmod -v 755 {} +
sudo find "${BASE_DIR}" -type f -name "*.conf" -exec sudo chmod -v 666 {} +
sudo find "${BASE_DIR}" -type f -name "*.env" -exec sudo chmod -v 666 {} +

echo
echo "========================================================"
echo "Starting Docker Compose..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${CLOUDFLARE_COMPOSE_FILE} up --build -d"

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

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
# Add required dependencies for the jenkins package
sudo yum install -y fontconfig java-17-openjdk
sudo yum install -y jenkins

# sudo update-alternatives --config java
sudo systemctl daemon-reload

sudo systemctl enable --now jenkins

sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

echo
echo "========================================================"
echo "Jenkins credential"
echo "========================================================"
echo

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
