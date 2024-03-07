#!/bin/bash


# this script will install the fixpack for IBM MQ by taking the file name as input
# Usage (single line):
#   wget "https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_IBM_MQ_Fixpack_rhel.sh"; bash install_IBM_MQ_Fixpack_rhel.sh "h9.2.0-IBM-MQ-LinuxX64-FP0020.tar.gz"
# OR
# Usage:
#   wget "https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_IBM_MQ_Fixpack_rhel.sh"
#   bash install_IBM_MQ_Fixpack_rhel.sh "9.2.0-IBM-MQ-LinuxX64-FP0020.tar.gz"


# Check if a file name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Please provide the IBM MQ fixpack file name as an argument."
    exit 1
fi

# Get the file name from the command line argument
fixpack_file=$1

# Extract the contents of the tar file
echo "Extracting contents of $fixpack_file..."
tar -xvf $fixpack_file

# Install RPM packages
echo "Installing RPM packages..."
rpm -ivh *.rpm

# Display IBM MQ version
mq_version=$(dspmqver)
echo "IBM MQ Version: $mq_version"

echo "Installation completed successfully."
