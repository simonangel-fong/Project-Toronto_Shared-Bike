#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"

APP_ADMIN="aadmin"
APP_GROUP="appgroup"

ORACLE_COMPOSE_FILE="${GITHUB_DIR}/oracledb/compose.oracledb.prod.yaml"
ORACLE_CON="oracle19cDB"

echo
echo "========================================================"
echo "Stopping oracle container..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${ORACLE_COMPOSE_FILE} down"
