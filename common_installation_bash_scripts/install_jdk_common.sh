#!/bin/bash
# This script downloads and installs oracle jdk based on the input version.
# Note: this script cannot download the oracle jdk which require user authentication for ex: jdk 8 and 11
# Function to display usage and exit
usage() {
    echo "Usage: $0 <os_type> <jdk_major_version> <jdk_version>"
    echo "Example: $0 rhel 17 17.0.11"
    echo "Example: $0 ubuntu 21 21.0.3"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    usage
fi

# Set variables from the arguments
os_type="$1"
jdk_major_version="$2"
jdk_version="$3_linux"

# Set the download link based on the OS type and JDK version
if [ "$os_type" == "rhel" ]; then
    download_link="https://download.oracle.com/java/$jdk_major_version/archive/jdk-$jdk_version-x64_bin.rpm"
elif [ "$os_type" == "ubuntu" ]; then
    download_link="https://download.oracle.com/java/$jdk_major_version/archive/jdk-$jdk_version-x64_bin.deb"
else
    echo "Unsupported OS type. Use 'rhel' or 'ubuntu'."
    usage
fi

# Check if wget is installed, install if necessary
if ! command -v wget &> /dev/null; then
    echo "Installing wget..."
    if [ "$os_type" == "rhel" ]; then
        yum install wget -y
    else
        apt-get update && apt-get install -y wget
    fi
fi

# Download the JDK package
echo "Downloading Oracle JDK package..."
wget "$download_link"

# Extract the package filename
package_file=$(basename "$download_link")

# Install the JDK based on the OS type
if [ "$os_type" == "rhel" ]; then
    echo "Installing Oracle JDK..."
    rpm -ivh "$package_file"
elif [ "$os_type" == "ubuntu" ]; then
    echo "Installing Oracle JDK..."
    dpkg -i "$package_file"
    apt-get install -f -y
fi

# Cleanup: remove the downloaded file
echo "Cleaning up..."
rm -f "$package_file"

echo "Oracle JDK installation completed successfully!"