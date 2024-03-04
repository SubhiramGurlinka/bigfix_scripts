#!/bin/bash

# Note: this script installs MySQL on Debian-based systems. It works on Ubuntu and other Debian-based OS.
# This script is not limited to any specific version of Ubuntu; it's a generic script.
# But please validate the OS version and the download link of MySQL for that particular OS version before executing the script.
# Usage (single line):
#   curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mysql_ubuntu_script.sh; bash install_mysql_ubuntu_script.sh "https://downloads.mysql.com/archives/get/p/23/file/mysql-server_8.2.0-1ubuntu22.04_amd64.deb-bundle.tar"
# OR
# Usage:
#   curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mysql_ubuntu_script.sh
#   bash install_mysql_ubuntu_script.sh "https://downloads.mysql.com/archives/get/p/23/file/mysql-server_8.2.0-1ubuntu22.04_amd64.deb-bundle.tar"

# Function to display usage and exit
usage() {
    echo "Usage: $0 <download_link>"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    usage
fi

# Extract version using regex
DOWNLOAD_LINK="$1"
MYSQL_VERSION=$(echo "$DOWNLOAD_LINK" | grep -oP 'mysql-\K\d+\.\d+\.\d+')

# Extract filename from download link
FILENAME=$(basename "$DOWNLOAD_LINK")

# Set the root password and default authentication plugin
ROOT_PASSWORD=""
DEFAULT_AUTH_PLUGIN="1"

# Create debconf selections file
echo "mysql-community-server	mysql-community-server/re-root-pass password $ROOT_PASSWORD" | debconf-set-selections
echo "mysql-community-server	mysql-community-server/root-pass password $ROOT_PASSWORD" | debconf-set-selections
echo "mysql-community-server	mysql-community-server/remove-test-db select true" | debconf-set-selections
echo "mysql-community-server	mysql-community-server/select-boolean	boolean true" | debconf-set-selections
echo "mysql-community-server	mysql-community-server/auth-option select $DEFAULT_AUTH_PLUGIN" | debconf-set-selections

# Install necessary packages
apt-get update
apt-get install -y wget sudo perl libaio1 libmecab2 libnuma1 psmisc libmysqlclient-dev libjson-perl mecab-ipadic-utf8

# Download MySQL DEB bundle
wget "$DOWNLOAD_LINK"

# Extract MySQL DEB files
tar -xvf "$FILENAME"

# Install MySQL DEB files
dpkg -i mysql-common*.deb
dpkg -i mysql-community-client-plugins*.deb
dpkg -i mysql-community-client-core*.deb
dpkg -i mysql-community-client*.deb
dpkg -i mysql-community-server-core*.deb
dpkg -i mysql-client*.deb
dpkg -i mysql-community-server*.deb
dpkg -i mysql-community-server*.deb
dpkg -i mysql-community-test*.deb
dpkg -i mysql-community-test-debug*.deb

# Clean up
rm -f "$FILENAME"

# Output a message for manual steps
echo "Please note that additional dependencies may need to be installed manually. Check for any error messages during the installation."
