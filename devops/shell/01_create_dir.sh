#!/bin/bash

# === Parameters ===
BASE_DIR="/project"
SUBDIRS=("config" "env" "data" "export" "oradata" "orabackup")
OWNER="aadmin"
GROUP="aadmin"

# === Create Directories ===
for dir in "${SUBDIRS[@]}"; do
    mkdir -pv "${BASE_DIR}/${dir}"
done

# === Set Ownership ===
chown -R ${OWNER}:${GROUP} "$BASE_DIR"

# === Set Permissions ===
# Directories: readable and accessible
find "$BASE_DIR" -type f -name "*.sh" -exec chmod 755 {} \;

# Files: read-only
find "$BASE_DIR" -type f -name "*.env" -exec chmod 444 {} +
find "$BASE_DIR" -type f -name "*.conf" -exec chmod 444 {} +

# === Special Permissions for backup and export ===
chmod 0777 "${BASE_DIR}/orabackup"
chmod 0777 "${BASE_DIR}/export"
