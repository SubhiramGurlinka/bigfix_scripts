#!/bin/bash

# Check if a download link is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <download_link>"
    exit 1
fi

# Set the download link from the command-line argument
download_link="$1"

# Install wget if not already installed
if ! command -v wget &> /dev/null; then
    echo "Installing wget..."
    yum install wget -y
fi

# Download the MariaDB RPM package
echo "Downloading MariaDB RPM package..."
wget "$download_link"

# Extract the tar file
tar_file=$(basename "$download_link")
tar -xvf "$tar_file"

# Navigate to the extracted directory
rpm_dir="${tar_file%.tar}"
cd "$rpm_dir"

# Install MariaDB RPM packages, skipping broken dependencies
echo "Installing MariaDB RPM packages..."
yum install *.rpm --skip-broken -y

# Cleanup: remove downloaded files and extracted directory
echo "Cleaning up..."
rm -f "$tar_file"
rm -rf "$rpm_dir"

echo "MariaDB installation completed successfully."
