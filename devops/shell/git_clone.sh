#!/bin/bash

# === Parameters ===
GIT_REPO_URL="https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git"
GIT_BRANCH="feature-devops"
TARGET_DIR="/project/github"

# === Install git ===
sudo dnf install -y git

# === Prepare directory ===
mkdir -pv "$TARGET_DIR"
git config --global --add safe.directory "$TARGET_DIR"

# === Clone the specific branch ===
git clone --branch "$GIT_BRANCH" "$GIT_REPO_URL" "$TARGET_DIR"
