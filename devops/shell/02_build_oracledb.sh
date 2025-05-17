#!/bin/bash

echo
echo "========================================================"
echo "Cloning github code..."
echo "========================================================"
echo

# Remove and clone the latest github
sudo rm -rf /project/github
sudo mkdir -pv /project/github

# set git
sudo git config --global --add safe.directory /project/github
# clone code
sudo git clone --branch feature-devops https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git /project/github

sudo chown jenkins:jenkins -Rv /project/github
# set sh file permission
sudo find /project/github -type f -name "*.sh" -exec chmod 755 -v {} \ 

echo
echo "========================================================"
echo "Copying config and env files..."
echo "========================================================"
echo

sudo cp -rv /home/aadmin/config /project
sudo cp -rv /home/aadmin/env /project

echo
echo "========================================================"
echo "Starting up oracle container..."
echo "========================================================"
echo

docker compose -f /project/github/oracledb/compose.oracledb.prod.yaml up --build -d