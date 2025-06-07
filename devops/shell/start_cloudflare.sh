#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"

DPUMP_DIR="${BASE_DIR}/dpump"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"

APP_ADMIN="aadmin"
APP_GROUP="appgroup"

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

CLOUDFLARE_COMPOSE_FILE="${GITHUB_DIR}/cloudflare/compose.cloudflare.prod.yaml"

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
sudo chown 54321:54321 -Rv "${DPUMP_DIR}"
sudo chown 54321:54321 -Rv "${ORADATA_DIR}"
sudo chown 54321:54321 -Rv "${ORBACKUP_DIR}"
sudo chown 54321:54321 -Rv "${GITHUB_DIR}/oracledb/scripts"

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