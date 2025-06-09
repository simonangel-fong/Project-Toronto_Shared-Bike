#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
APP_ADMIN="appadmin"

BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"

CLOUDFLARE_COMPOSE_FILE="${GITHUB_DIR}/cloudflare/compose.cloudflare.prod.yaml"

echo
echo "========================================================"
echo "Starting Docker Compose: Cloudflare..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${CLOUDFLARE_COMPOSE_FILE} up --build -d"

echo
echo "========================================================"
echo "✅ Project setup completed successfully!"
echo "========================================================"
echo
