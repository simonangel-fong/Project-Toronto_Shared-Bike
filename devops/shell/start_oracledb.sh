#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
APP_ADMIN="aadmin"

BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"

ORACLE_COMPOSE_FILE="${GITHUB_DIR}/oracledb/compose.oracledb.prod.yaml"

echo
echo "========================================================"
echo "Starting Docker Compose: OracleDB..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${ORACLE_COMPOSE_FILE} up --build -d"

echo
echo "========================================================"
echo "✅ Project setup completed successfully!"
echo "========================================================"
echo