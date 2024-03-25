#!/bin/bash

# Note: This script installs MongoDB on RHEL-based systems.
# It works on RHEL, Rocky Linux, and other RHEL-based distributions.
# This script is not limited to any specific version of RHEL; it is designed to be generic.
# However, it's essential to validate the OS version in the download link of MongoDB with the actual version of the OS before executing the script.
# The script automatically detects the package manager (dnf or yum) available on the system and uses it to install packages.
# It first displays the OS details by reading /etc/os-release.
# The user is prompted to enter the MongoDB version and the major version of the OS.
# After that, the script downloads the MongoDB packages from the official MongoDB repository based on the provided version and OS version.
# The downloaded packages are then installed using the detected package manager.
# Once the installation is complete, the script shows the installed MongoDB version and lists all MongoDB-related packages using rpm -qa | grep mongo.
# Additionally, the script asks the user if they want to restart the BES client. If the user chooses to restart, the script attempts to restart the BES client with a timeout of 15 seconds.
# If the restart fails within the timeout, the script starts the BES client instead.
# Usage:
# 1. Run the script directly or download it using curl:
#    curl -O https://raw.githubusercontent.com/your_username/your_repo/main/install_mongodb_rhel_script.sh
# 2. Execute the script with appropriate permissions:
#    bash install_mongodb_rhel_script.sh
# 3. Follow the prompts to enter the MongoDB version and OS version.
# 4. After installation, review the installed MongoDB version and packages.
# 5. Optionally, decide whether to restart the BES client when prompted.

# Display OS details
cat /etc/os-release
echo
echo

# Ask for MongoDB version
read -p "Enter MongoDB version (e.g., 7.0.5): " version
echo

# Ask for OS version
read -p "Enter OS version (e.g., major version of the OS like 7 or 8 or 9): " os_version
echo

# Extract the first two digits of the version
major_version=$(echo "$version" | cut -d. -f1-2)

# Check which package manager to use
if command -v dnf &> /dev/null; then
    package_manager="dnf"
elif command -v yum &> /dev/null; then
    package_manager="yum"
else
    echo "Neither dnf nor yum package manager found. Exiting."
    exit 1
fi

# Install wget
$package_manager install -y sudo
sudo $package_manager install -y wget

# Download MongoDB packages
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-tools-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-server-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-mongos-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-database-tools-extra-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-database-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-org-$version-1.el$os_version.x86_64.rpm"
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-mongosh-2.2.1.x86_64.rpm"
sudo wget "https://repo.mongodb.org/$package_manager/redhat/$os_version/mongodb-org/$major_version/x86_64/RPMS/mongodb-database-tools-100.9.4.x86_64.rpm"

# Install MongoDB packages
sudo $package_manager install -y mongodb*.rpm

# Clean up
sudo rm -f mongodb*.rpm

# Show installed MongoDB version and packages
echo "Installed MongoDB version: $version"
rpm -qa | grep mongo

# Ask if the user wants to restart the BES client
read -p "Do you want to restart the BES client? (y/n): " restart_choice
if [[ $restart_choice == "y" || $restart_choice == "Y" ]]; then
    # Restart BES client with a timeout of 15 seconds
    /etc/init.d/besclient restart &
    sleep 15
    # Check if BES client restarted, if not, start it
    if ! ps -ef | grep -q "[b]esclient"; then
        /etc/init.d/besclient start
    fi
else
    echo "BES client not restarted."
fi
