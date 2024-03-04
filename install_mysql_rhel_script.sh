#!/bin/bash

# Note: this script install mysql on RHEL family. so it works on RHEL, rocky and other rhel based OS
# This sript is not limited to any specific version of RHEL this is a generic script. but please validate the os version and the download link of myswl for that particualr os version before executing the script
# usage (single line):
#  curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mysql_rhel_script.sh; bash install_mysql_rhel_script.sh "https://downloads.mysql.com/archives/get/p/23/file/mysql-8.2.0-1.el8.x86_64.rpm-bundle.tar" 
# OR
# usage :
#   curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mysql_rhel_script.sh
#    bash install_mysql_rhel_script.sh "https://downloads.mysql.com/archives/get/p/23/file/mysql-8.2.0-1.el8.x86_64.rpm-bundle.tar" 
#
#
# Function to display usage and exit
usage() {
    echo "Usage: $0 <download_link>"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    usage
fi

# Extract version and OS using regex
DOWNLOAD_LINK="$1"
MYSQL_VERSION=$(echo "$DOWNLOAD_LINK" | grep -oP 'mysql-\K\d+\.\d+\.\d+')
OS_VERSION=$(echo "$DOWNLOAD_LINK" | grep -oP 'el\d+')

# Validate OS version
if [ -z "$OS_VERSION" ]; then
    echo "Error: Unable to extract OS version from the download link."
    usage
fi

# Extract filename from download link
FILENAME=$(basename "$DOWNLOAD_LINK")

# Install necessary packages
yum install -y wget sudo perl libaio numactl net-tools openssl-devel openssl-libs libtirpc libcrypto.so.1.1 perl-JSON

# Download MySQL RPM bundle
wget "$DOWNLOAD_LINK"

# Extract and install MySQL RPMs
tar -xvf "$FILENAME"

# Install MySQL RPMs
rpm -ivh mysql-community-icu-data-files-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-common-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-client-plugins-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-libs-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-client-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-server-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-debuginfo-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-client-debuginfo-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-client-plugins-debuginfo-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-debugsource-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-devel-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-libs-debuginfo-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-server-debug-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-server-debug-debuginfo-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-server-debuginfo-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-test-${MYSQL_VERSION}*.rpm
rpm -ivh mysql-community-test-debuginfo-${MYSQL_VERSION}*.rpm
# Clean up
rm -f "$FILENAME"

