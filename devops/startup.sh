#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
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
echo "Update conf and env file"
echo "========================================================"
echo

sudo rm -rfv $CONFIG_DIR
sudo cp -rv /root/config/ $BASE_DIR
# confirm
ls -l $CONFIG_DIR

echo
echo "========================================================"
echo "Cloning GitHub repository..."
echo "========================================================"
echo

sudo rm -rfv $GITHUB_DIR
sudo mkdir -pv $GITHUB_DIR

su - $APP_ADMIN -c "git config --global --add safe.directory ${GITHUB_DIR}"
sudo git clone --branch $GIT_BRANCH $GIT_REPO_URL $GITHUB_DIR

sudo chown $APP_ADMIN:$APP_GROUP -Rv $BASE_DIR

# Set shell script permissions
sudo find $GITHUB_DIR -type f -name "*.sh" -exec chmod -v 755 {} +

# Set permissions
find $BASE_DIR -type d -exec chmod -v 755 {} +
find $BASE_DIR -type f -name "*.conf" -exec chmod -v 666 {} +
find $BASE_DIR -type f -name "*.env" -exec chmod -v 666 {} +

sudo chmod -v 777 $DPUMP_DIR
sudo chmod 0777 -v $ORADATA_DIR
sudo chmod 0777 -v $ORBACKUP_DIR

echo
echo "========================================================"
echo "Starting up oracle container..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${ORACLE_COMPOSE_FILE} up --build -d"
