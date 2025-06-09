#!/bin/bash

# As root
set -e          # Exit on error
set -o pipefail # Propagate pipeline failures
set -u          # Treat unset variables as errors

# ========== Environment Variables ==========

BASE_DIR="/project"
GITHUB_DIR="${BASE_DIR}/github"
CONFIG_DIR="${BASE_DIR}/config"

SOURCE_DIR="${BASE_DIR}/source"
DPUMP_DIR="${BASE_DIR}/dpump"
ORADATA_DIR="${BASE_DIR}/oradata"
ORBACKUP_DIR="${BASE_DIR}/orabackup"

APP_ADMIN="aadmin"
APP_GROUP="appgroup"

# List of URLs to download
SOURCE_URLS=(
    "https://trip.arguswatcher.net/source/2019/Ridership-2019-Q1.csv"
    "https://trip.arguswatcher.net/source/2019/Ridership-2019-Q2.csv"
    "https://trip.arguswatcher.net/source/2019/Ridership-2019-Q3.csv"
    "https://trip.arguswatcher.net/source/2019/Ridership-2019-Q4.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-01.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-02.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-03.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-04.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-05.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-06.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-07.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-08.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-09.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-10.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-11.csv"
    "https://trip.arguswatcher.net/source/2020/Ridership-2020-12.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-01.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-02.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-03.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-04.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-05.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-06.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-07.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-08.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-09.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-10.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-11.csv"
    "https://trip.arguswatcher.net/source/2021/Ridership-2021-12.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-01.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-02.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-03.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-04.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-05.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-06.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-07.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-08.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-09.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-10.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-11.csv"
    "https://trip.arguswatcher.net/source/2022/Ridership-2022-12.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-01.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-02.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-03.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-04.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-05.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-06.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-07.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-08.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-09.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-10.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-11.csv"
    "https://trip.arguswatcher.net/source/2023/Ridership-2023-12.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-01.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-02.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-03.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-04.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-05.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-06.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-07.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-08.csv"
    "https://trip.arguswatcher.net/source/2024/Ridership-2024-09.csv"
)

echo
echo "========================================================"
echo "Downloading source data"
echo "========================================================"
echo

# Check if source directory exists and is empty
if [ -d "$SOURCE_DIR" ] && [ -z "$(ls -A "$SOURCE_DIR")" ]; then
    echo "Source Data Directory is ready."
else
    echo "Remove existing data and recreate directory"
    sudo rm -rf "${SOURCE_DIR}"
    sudo mkdir -pv "${SOURCE_DIR}"
fi

for url in "${SOURCE_URLS[@]}"; do
    year=$(echo "${url}" | cut -d'/' -f5) # Extract year from URL
    dir="${SOURCE_DIR}/${year}"           # Destination directory for each year

    # Check if year directory exists; create if it doesn't
    if [ ! -d "$dir" ]; then
        sudo mkdir -pv "${dir}"
        echo "Directory for ${year} is created."
    fi

    # Download file
    echo "Downloading from: ${url}"
    sudo wget -P "${dir}" "${url}"

done

echo
echo "========================================================"
echo "Set ownership..."
echo "========================================================"
echo

# Set ownership for admin
sudo chown "${APP_ADMIN}":"${APP_GROUP}" -Rv "${BASE_DIR}"

# Set ownership for oracle
sudo chown 54321:54321 -Rv "${DPUMP_DIR}" "${ORADATA_DIR}" "${ORBACKUP_DIR}" "${GITHUB_DIR}/oracledb/scripts"

# Set shell script permissions
sudo find "${GITHUB_DIR}" -type f -name "*.sh" -exec chmod -v 755 {} +
# Set permissions for directories and files
sudo find "${BASE_DIR}" -type d -exec sudo chmod -v 755 {} +
sudo find "${BASE_DIR}" -type f \( -name "*.conf" -o -name "*.env" \) -exec sudo chmod -v 666 {} +

echo
echo "========================================================"
echo "Download completed."
echo "========================================================"
echo
