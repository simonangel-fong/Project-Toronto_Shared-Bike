#!/bin/bash

# as root

set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
BASE_DIR="/project"

GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"
ENV_DIR="${BASE_DIR}/env"

DATA_DIR="${BASE_DIR}/data"
EXPORT_DIR="${BASE_DIR}/export"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"

DIR_USER="jenkins"
DIR_GROUP="jenkins"

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

ORACLE_COMPOSE_FILE="${GITHUB_DIR}/oracledb/compose.oracledb.prod.yaml"
ORACLE_CON="oracle19cDB"

echo
echo "========================================================"
echo "Removing existing project directories..."
echo "========================================================"
echo

sudo rm -rf "${GITHUB_DIR}" "${CONFIG_DIR}" "${ENV_DIR}"

echo
echo "========================================================"
echo "Creating project directories..."
echo "========================================================"
echo

sudo mkdir -pv "${GITHUB_DIR}" "${CONFIG_DIR}" "${ENV_DIR}" "${DATA_DIR}" "${EXPORT_DIR}" "${ORADATA_DIR}" "${ORBACKUP_DIR}"

echo
echo "========================================================"
echo "Cloning GitHub repository..."
echo "========================================================"
echo

sudo rm -rf "${GITHUB_DIR}"
sudo mkdir -pv "${GITHUB_DIR}"
sudo chown "${DIR_USER}":"${DIR_GROUP}" -Rv "${GITHUB_DIR}"

git config --global --add safe.directory "${GITHUB_DIR}"
git clone --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${GITHUB_DIR}"

# Set shell script permissions
sudo find "${GITHUB_DIR}" -type f -name "*.sh" -exec chmod -v 755 {} +

echo
echo "========================================================"
echo "Copying config and env files..."
echo "========================================================"
echo

sudo cp -rv /home/aadmin/config/ "${BASE_DIR}"
sudo cp -rv /home/aadmin/env/ "${BASE_DIR}"

sudo chown "${DIR_USER}":"${DIR_GROUP}" -Rv "${BASE_DIR}"

# Set permissions
find "${BASE_DIR}" -type d -exec chmod -v 755 {} +
find "${BASE_DIR}" -type f -name "*.conf" -exec chmod -v 666 {} +
find "${BASE_DIR}" -type f -name "*.env" -exec chmod -v 666 {} +

sudo chmod 0777 -v "${ORADATA_DIR}"
sudo chmod 0777 -v "${ORBACKUP_DIR}"

echo
echo "========================================================"
echo "✅ Project setup completed successfully!"
echo "========================================================"
echo
