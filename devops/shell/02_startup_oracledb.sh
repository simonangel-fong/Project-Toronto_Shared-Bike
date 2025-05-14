#!/bin/bash

GITHUB_DIR="/project/github"

cd $GITHUB_DIR
# pull the latest version
git pull

# Create container
docker compose -f /project/github/oracledb/compose.oracledb.prod.yaml up --build -d && docker exec -it -u root:root oracle19cDB bash /project/scripts/init/init.sh