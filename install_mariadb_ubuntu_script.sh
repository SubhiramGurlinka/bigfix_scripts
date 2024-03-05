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
    echo "Installing sudo and wget..."
    apt-get install sudo -y
    sudo apt-get update
    sudo apt-get install wget -y
fi

# Download the MariaDB DEB package
echo "Downloading MariaDB DEB package..."
wget "$download_link"

# Extract the tar file
tar_file=$(basename "$download_link")
tar -xvf "$tar_file"

# Navigate to the extracted directory
deb_dir="${tar_file%.tar.gz}"
cd "$deb_dir"

# Install MariaDB DEB packages
echo "Installing MariaDB DEB packages..."
sudo dpkg -i *.deb

# Install dependencies if needed
sudo apt-get install -f -y

# Cleanup: remove downloaded files and extracted directory
echo "Cleaning up..."
rm -f "$tar_file"
rm -rf "$deb_dir"

echo "MariaDB installation completed successfully."
