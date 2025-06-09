#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========
APP_ADMIN="aadmin"

BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"

PROMETHEUS_COMPOSE_FILE="${GITHUB_DIR}/prometheus/compose.prometheus.prod.yaml"

echo
echo "========================================================"
echo "Starting Docker Compose..."
echo "========================================================"
echo

su - $APP_ADMIN -c "docker compose -f ${PROMETHEUS_COMPOSE_FILE} up --build -d"

echo
echo "========================================================"
echo "Add port 3100 for Grafana..."
echo "========================================================"
echo

sudo firewall-cmd --permanent --add-port=3100/tcp

echo
echo "========================================================"
echo "✅ Project setup completed successfully!"
echo "========================================================"
echo
