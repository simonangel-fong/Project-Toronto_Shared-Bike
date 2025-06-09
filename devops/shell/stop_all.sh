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
if [ -n "$(docker ps -a -q)" ]; then
    docker stop $(docker ps -a -q)
fi

docker system prune -f
