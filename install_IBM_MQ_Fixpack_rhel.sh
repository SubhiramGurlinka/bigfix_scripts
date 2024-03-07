#!/bin/bash

# Check if a file name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Please provide the IBM MQ fixpack file name as an argument."
    exit 1
fi

# Get the file name from the command line argument
fixpack_file=$1
folder_name="${fixpack_file%.tar.gz}"

# Create a new folder and move the fixpack file into it
echo "Creating and entering the folder: $folder_name"
mkdir $folder_name
mv $fixpack_file $folder_name
cd $folder_name

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
