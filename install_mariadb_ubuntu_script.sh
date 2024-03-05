#!/bin/bash
#
# usage:
# single line command:
# curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mariadb_ubuntu_script.sh; bash install_mariadb_ubuntu_script.sh "https://downloads.mariadb.com/MariaDB/mariadb-10.11.1/repo/ubuntu/mariadb-10.11.1-ubuntu-jammy-amd64-debs.tar"
# usage:
# curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mariadb_ubuntu_script.sh
# bash install_mariadb_ubuntu_script.sh "https://downloads.mariadb.com/MariaDB/mariadb-10.11.1/repo/ubuntu/mariadb-10.11.1-ubuntu-jammy-amd64-debs.tar"
# Replace the MariaDB download link in the examples with the appropriate link for the version you want to install. Ensure the link points to a valid MariaDB DEB package for the desired Ubuntu version.

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
    apt-get update
    apt-get install wget -y
fi

# Download the MariaDB TAR file
echo "Downloading MariaDB TAR file..."
wget "$download_link"

# Extract the tar file
tar_file=$(basename "$download_link")
tar -xvf "$tar_file"

# Navigate to the extracted directory
rpm_dir="${tar_file%.tar}"
cd "$rpm_dir"

# Install MariaDB DEB packages
echo "Installing MariaDB DEB packages..."
dpkg -i *.deb

# Install dependencies if needed
apt-get install -f -y

# Cleanup: remove downloaded files and extracted directories
echo "Cleaning up..."
rm -f "$tar_file"
rm -rf "$inner_tar_file"

echo "MariaDB installation completed successfully."
