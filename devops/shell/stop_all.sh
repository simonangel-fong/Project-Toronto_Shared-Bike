#!/bin/bash

# as aadmin
set -e # Exit on error
set -o pipefail
set -u # Treat unset variables as error

# ========== Environment Variables ==========

echo
echo "========================================================"
echo "Stopping Docker..."
echo "========================================================"
echo

# stop all container and remove tangling resources
sudo docker stop $(docker ps -a -q) && docker system prune -f
