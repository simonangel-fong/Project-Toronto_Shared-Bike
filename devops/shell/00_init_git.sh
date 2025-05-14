#!/bin/bash

# === Parameters ===
BASE_DIR="/project"
GITHUB_DIR="/project/github"
CONFIG_DIR="/project/github"
ENV_DIR="/project/env"
DATA_DIR="/project/data"
EXPORT_DIR="/project/export"
ORADATA_DIR="/project/oradata"
ORBACKUP_DIR="/project/orabackup"

GIT_USER="aadmin"
GIT_GROUP="aadmin"

GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"

echo
echo "########################################################"
echo "Cleaning Directories...                         "
echo "########################################################"

rm -rfv $BASE_DIR

echo
echo "########################################################"
echo "Creating Directories...                         "
echo "########################################################"

mkdir -pv $GITHUB_DIR
mkdir -pv $CONFIG_DIR
mkdir -pv $ENV_DIR
mkdir -pv $DATA_DIR
mkdir -pv $EXPORT_DIR
mkdir -pv $ORADATA_DIR
mkdir -pv $ORBACKUP_DIR

echo
echo "########################################################"
echo "Installing git"
echo "########################################################"

sudo dnf install -y git

echo
echo "########################################################"
echo "Cloning Github repo"
echo "########################################################"

git config --global --add safe.directory "$GITHUB_DIR"
git clone --branch "$GIT_BRANCH" "$GIT_REPO_URL" "$GITHUB_DIR"

echo
echo "########################################################"
echo "Setting permission"
echo "########################################################"

# === Set Ownership ===
chown -Rv ${GIT_USER}:${GIT_GROUP} "$BASE_DIR"

# === Set Permissions ===
# Directories: readable and accessible
find "$BASE_DIR" -type d -exec chmod 755 {} \;

find "$BASE_DIR" -type f -name "*.sh" -exec chmod -v 755 {} \;
# Files: read-only
find "$BASE_DIR" -type f -name "*.env" -exec chmod -v 444 {} +
find "$BASE_DIR" -type f -name "*.conf" -exec chmod -v 444 {} +

# === Special Permissions for backup and export ===
chmod 0777 "${BASE_DIR}/orabackup"
chmod 0777 "${BASE_DIR}/export"
