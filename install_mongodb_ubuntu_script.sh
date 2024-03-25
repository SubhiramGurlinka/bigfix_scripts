#!/bin/bash

# Note: This script installs MongoDB on Ubuntu. It is designed to work on Ubuntu 18.04 (Bionic), Ubuntu 20.04 (Focal), and Ubuntu 22.04 (Jammy).
# This script dynamically selects the appropriate Ubuntu version based on user input and installs MongoDB accordingly.
# The script downloads MongoDB packages from the official MongoDB repository for the selected Ubuntu version and MongoDB version.
# The downloaded packages are installed using dpkg and are not renamed.
# After installation, the script displays the installed MongoDB version and packages.
# Additionally, it prompts the user if they want to restart the BES client, allowing them to choose whether or not to restart.

# Usage:
# 1. Run the script with the appropriate parameters:
#    wget "https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mongodb_ubuntu_script.sh"
#    bash install_mongodb_ubuntu_script.sh
# 2. Follow the prompts to select the Ubuntu version and enter the MongoDB version.
# 3. After installation, the script will display the installed MongoDB version and packages.
# 4. Optionally, the script will ask if you want to restart the BES client.


# Display OS details
cat /etc/os-release
echo
echo

# Select Ubuntu version
echo "Select your Ubuntu version:"
echo "1. Ubuntu 22.04 (Jammy)"
echo "2. Ubuntu 20.04 (Focal)"
echo "3. Ubuntu 18.04 (Bionic)"
read -p "Enter your choice (1, 2, or 3): " os_choice
echo

case $os_choice in
    1)
        ubuntu_version="jammy"
        ;;
    2)
        ubuntu_version="focal"
        ;;
    3)
        ubuntu_version="bionic"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

apt-get install -y sudo

# Ask for MongoDB version
read -p "Enter MongoDB version (e.g., 7.0.5): " version
echo

# Download MongoDB packages
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-mongosh_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-database-tools_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-org-database-tools-extra_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-org-shell_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-org-mongos_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-org-tools_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-org-database_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-org-server_${version}_amd64.deb"
sudo wget "https://repo.mongodb.org/apt/ubuntu/dists/$ubuntu_version/mongodb-org/$version/multiverse/binary-amd64/mongodb-org_${version}_amd64.deb"

# Install MongoDB packages
sudo dpkg -i mongodb-mongosh_${version}_amd64.deb
sudo dpkg -i mongodb-database-tools_${version}_amd64.deb
sudo dpkg -i mongodb-org-database-tools-extra_${version}_amd64.deb
sudo dpkg -i mongodb-org-shell_${version}_amd64.deb
sudo dpkg -i mongodb-org-mongos_${version}_amd64.deb
sudo dpkg -i mongodb-org-tools_${version}_amd64.deb
sudo dpkg -i mongodb-org-database_${version}_amd64.deb
sudo dpkg -i mongodb-org-server_${version}_amd64.deb
sudo dpkg -i mongodb-org_${version}_amd64.deb

# Clean up
sudo rm -f mongodb-org-*.deb

# Show installed MongoDB version and packages
echo "Installed MongoDB version: $version"
dpkg -l | grep mongo

# Ask if the user wants to restart the BES client
read -p "Do you want to restart the BES client? (y/n): " restart_choice
if [[ $restart_choice == "y" || $restart_choice == "Y" ]]; then
    # Restart BES client with a timeout of 15 seconds
    systemctl restart besclient &
    sleep 15
    # Check if BES client restarted, if not, start it
    if ! ps -ef | grep -q "[b]esclient"; then
        systemctl start besclient
    fi
else
    echo "BES client not restarted."
fi
