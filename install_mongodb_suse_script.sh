#!/bin/bash

# Note: This script installs MongoDB on openSUSE-based systems.
# It is designed to work with openSUSE distributions.
# This script is not limited to any specific version of openSUSE; it is designed to be generic.
# The script automatically detects the package manager (zypper) available on the system and uses it to install packages.
# It first displays the OS details by reading /etc/os-release.
# The user is prompted to enter the MongoDB version and the major version of the OS.
# After that, the script downloads the MongoDB packages from the official MongoDB repository based on the provided version and OS version.
# The downloaded packages are then installed using the detected package manager.
# Once the installation is complete, the script shows the installed MongoDB version and lists all MongoDB-related packages using rpm -qa | grep mongo.
# Usage:
# 1. Run the script directly or download it using curl:
#    curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mongodb_suse_script.sh
# 2. Execute the script with appropriate permissions:
#    bash install_mongodb_suse_script.sh
# 3. Follow the prompts to enter the MongoDB version and OS version.
# 4. After installation, review the installed MongoDB version and packages.

# Display OS details
cat /etc/os-release
echo
echo

# Ask for MongoDB version
read -p "Enter MongoDB version (e.g., 7.0.5): " version
echo

# Ask for OS version
read -p "Enter OS version (e.g., major version of the OS like '12' or '15'): " os_version
echo

# Extract the first two digits of the version
major_version=$(echo "$version" | cut -d. -f1-2)

package_manager="zypper"

# Install wget
$package_manager install -y sudo
sudo $package_manager install -y wget

# Download MongoDB packages
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-tools-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-server-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-mongos-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-database-tools-extra-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-database-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-mongosh-2.2.1.x86_64.rpm"
sudo wget "https://repo.mongodb.org/zypper/suse/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-database-tools-100.9.4.x86_64.rpm"

# Install MongoDB packages
sudo $package_manager install -y mongodb*.rpm

# Clean up
sudo rm -f mongodb*.rpm

# Show installed MongoDB version and packages
echo "Installed MongoDB version: $version"
rpm -qa | grep mongo

# Ask if the user wants to restart the BES client
# read -p "Do you want to restart the BES client? (y/n): " restart_choice
# if [[ $restart_choice == "y" || $restart_choice == "Y" ]]; then
#     # Restart BES client with a timeout of 15 seconds
#     /etc/init.d/besclient restart &
#     sleep 15
#     # Check if BES client restarted, if not, start it
#     if ! ps -ef | grep -q "[b]esclient"; then
#         /etc/init.d/besclient start
#     fi
# else
#     echo "BES client not restarted."
# fi