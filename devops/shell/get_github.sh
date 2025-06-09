#!/bin/bash

# as root
set -e          # Exit on error
set -o pipefail # Propagate pipeline failures
set -u          # Treat unset variables as errors

# ========== Environment Variables ==========
BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"

DPUMP_DIR="${BASE_DIR}/dpump"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"
CONFIG_DIR="${BASE_DIR}/config"

APP_ADMIN="aadmin"
APP_GROUP="appgroup"

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

# Check if GITHUB_DIR exists and is empty
if [ -d "$GITHUB_DIR" ] && [ ! -z "$(ls -A "$GITHUB_DIR")" ]; then
    rm -rf "${GITHUB_DIR}"
else
    echo
    echo "========================================================"
    echo "Cloning GitHub repository..."
    echo "========================================================"
    echo
    # clone the repository
    git clone --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${GITHUB_DIR}"
fi

echo
echo "========================================================"
echo "Copy conf and env file"
echo "========================================================"
echo

cp -rv ~/config/ ${BASE_DIR}
# confirm
ls $CONFIG_DIR

echo
echo "========================================================"
echo "Set ownership..."
echo "========================================================"
echo

# Set ownership for admin
chown "${APP_ADMIN}":"${APP_GROUP}" -Rv "${BASE_DIR}"

# Set ownership for oracle
chown 54321:54321 -Rv "${DPUMP_DIR}" "${ORADATA_DIR}" "${ORBACKUP_DIR}" "${GITHUB_DIR}/oracledb/scripts"

# Set shell script permissions
find "${GITHUB_DIR}" -type f -name "*.sh" -exec chmod -v 755 {} +
# Set permissions for directories and files
find "${BASE_DIR}" -type d -exec chmod -v 755 {} +
find "${BASE_DIR}" -type f \( -name "*.conf" -o -name "*.env" \) -exec chmod -v 666 {} +
