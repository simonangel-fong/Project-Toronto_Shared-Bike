#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"

APP_ADMIN="aadmin"
APP_GROUP="appgroup"

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

echo
echo "========================================================"
echo "Refresh GitHub repository..."
echo "========================================================"
echo

sudo rm -rf $GITHUB_DIR
sudo mkdir -pv $GITHUB_DIR

# sudo git config --global --add safe.directory "${GITHUB_DIR}"
sudo git clone --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${GITHUB_DIR}"

sudo chown "${APP_ADMIN}":"${APP_GROUP}" -Rv "${BASE_DIR}"

# Set shell script permissions
sudo find "${GITHUB_DIR}" -type f -name "*.sh" -exec chmod -v 755 {} +
