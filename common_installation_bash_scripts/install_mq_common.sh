#!/bin/bash

# give the file name as an input, since we are not able to access the download URL for this file
# Usage (single line):
#   wget "https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_IBM_MQ_rhel_script.sh"; bash install_IBM_MQ_rhel_script.sh "9.2.0.0-IBM-MQTRIAL-LinuxX64.tar.gz"
# OR
# Usage:
#   wget "https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_IBM_MQ_rhel_script.sh"
#   bash install_IBM_MQ_rhel_script.sh "9.2.0.0-IBM-MQTRIAL-LinuxX64.tar.gz"


# Function to display usage information
display_usage() {
    echo "Usage: $0 <input_file>"
    echo "Provide the input file with .tar or .tar.gz extension."
    exit 1
}

# Function to check and install packages
install_package() {
    PACKAGE_NAME=$1
    if ! command -v $PACKAGE_NAME &> /dev/null; then
        echo "$PACKAGE_NAME not found. Installing..."
        sudo yum install -y $PACKAGE_NAME
        if [ $? -ne 0 ]; then
            echo "Failed to install $PACKAGE_NAME. Exiting."
            exit 1
        fi
    fi
}

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    display_usage
fi

INPUT_FILE=$1

# Check and install required packages
install_package "gunzip"
install_package "tar"

# Check the file extension
if [[ "$INPUT_FILE" == *".tar.gz" ]]; then
    # Unzip if the file is .tar.gz
    tar -xzf "$INPUT_FILE"
elif [[ "$INPUT_FILE" == *".tar" ]]; then
    # Unzip if the file is .tar
    tar -xf "$INPUT_FILE"
else
    echo "Invalid file extension. Supported extensions are .tar and .tar.gz."
    display_usage
fi

# Change to MQServer folder
cd MQServer || exit 1

# Accept the license agreement
./mqlicense.sh <<EOF
1
EOF

# Install MQSeries
rpm -ivh MQSeries*.rpm

# Change directory to /opt/mqm/bin
cd /opt/mqm/bin || exit 1

# Run setmqinst to set the installation path
./setmqinst -i -p /opt/mqm

# Switch to mqm user
su mqm <<EOF
dspmqver
EOF

# Exit the installation
echo "Installation completed successfully."