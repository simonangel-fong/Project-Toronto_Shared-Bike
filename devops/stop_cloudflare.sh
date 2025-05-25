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

CLOUDFLARE_COMPOSE_FILE="${GITHUB_DIR}/cloudflare/compose.cloudflare.prod.yaml"

echo
echo "========================================================"
echo "Stopping oracle container..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${CLOUDFLARE_COMPOSE_FILE} down"
