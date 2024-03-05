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
cd "${tar_file%.tar}"

# Install MariaDB DEB packages
echo "Installing MariaDB DEB packages..."
for deb_package in *.deb; do
    dpkg -i "$deb_package"
done

# Install dependencies if needed
apt-get install -f -y

echo "Installing MariaDB DEB packages..."
for deb_package in *.deb; do
    dpkg -i "$deb_package"
done
# Cleanup: remove downloaded files and extracted directory
echo "Cleaning up..."
cd ..
rm -rf "${tar_file%.tar}"

echo "MariaDB installation completed successfully."
