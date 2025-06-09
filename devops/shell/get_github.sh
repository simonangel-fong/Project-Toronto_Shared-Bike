#!/bin/bash

# as root
set -e         # Exit on error
set -o pipefail   # Propagate pipeline failures
set -u         # Treat unset variables as errors

# ========== Environment Variables ==========
BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"

DPUMP_DIR="${BASE_DIR}/dpump"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"
CONFIG_DIR="${BASE_DIR}/config"

APP_ADMIN="appadmin"
APP_GROUP="appgroup"

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

# Check if GITHUB_DIR exists and is empty
if [ -d "$GITHUB_DIR" ] && [ -z "$(ls -A "$GITHUB_DIR")" ]; then
    echo
    echo "========================================================"
    echo "Cloning GitHub repository..."
    echo "========================================================"
    echo
    # clone the repository
    sudo git clone --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${GITHUB_DIR}"
else
    echo
    echo "========================================================"
    echo "Pulling GitHub repository..."
    echo "========================================================"
    echo
    # Directory exists and is not empty, force pull the repository
    sudo git -C "${GITHUB_DIR}" fetch origin
    sudo git -C "${GITHUB_DIR}" reset --hard "origin/${GIT_BRANCH}"
    sudo git -C "${GITHUB_DIR}" clean -df
    sudo git -C "${GITHUB_DIR}" checkout "${GIT_BRANCH}"
    sudo git -C "${GITHUB_DIR}" pull
fi

git config --global --add safe.directory "${GITHUB_DIR}"

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
echo "Set ownership..."
echo "========================================================"
echo

# Set ownership for admin
sudo chown "${APP_ADMIN}":"${APP_GROUP}" -Rv "${BASE_DIR}"

# Set ownership for oracle
sudo chown 54321:54321 -Rv "${DPUMP_DIR}" "${ORADATA_DIR}" "${ORBACKUP_DIR}" "${GITHUB_DIR}/oracledb/scripts"

# Set shell script permissions
sudo find "${GITHUB_DIR}" -type f -name "*.sh" -exec chmod -v 755 {} +
# Set permissions for directories and files
sudo find "${BASE_DIR}" -type d -exec sudo chmod -v 755 {} +
sudo find "${BASE_DIR}" -type f \( -name "*.conf" -o -name "*.env" \) -exec sudo chmod -v 666 {} +