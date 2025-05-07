#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     init_system.sh
# Description:     This script initializes the system by upgrading packages,
#                  installing required utilities, and preparing project scripts.
# Usage:           Run as root user.
# -----------------------------------------------------------------------------

# Upgrade all installed packages to the latest version
yum update -y

# Install dos2unix utility to convert Windows-style line endings
yum install -y dos2unix

# Set ownership and permissions for project scripts directory
chown -R oracle:oinstall /project/scripts # Set owner to oracle:oinstall
chmod -R 0755 /project/scripts/           # Ensure scripts are executable

# Convert all script files in /project/scripts from CRLF to LF format
find /project/scripts/ -type f -exec dos2unix {} \;
