#!/bin/bash

# Function to display usage and exit
usage() {
    echo "Usage: $0 <os_name> <os_version> <postgres_version>"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    usage
fi

# Assign input arguments to variables
os_name="$1"
os_version="$2"
postgres_version="$3"

# Function to extract major version number from a version string
extract_major_version() {
    local version_string="$1"
    # Use parameter expansion to get the part before the dot
    major_version="${version_string%%.*}"
    echo "$major_version"
}
major_version=$(extract_major_version "$postgres_version")
echo "Major version: $major_version"

# Set download links based on the OS type and Postgres version
if [ "$os_name" == "rhel" ]; then
    base_url="https://download.postgresql.org/pub/repos/yum/$major_version/redhat/rhel-$os_version-x86_64"
    download_links=(
        "$base_url/postgresql${major_version}-${postgres_version}-1PGDG.rhel${os_version}.x86_64.rpm"
        "$base_url/postgresql${major_version}-server-${postgres_version}-1PGDG.rhel${os_version}.x86_64.rpm"
        "$base_url/postgresql${major_version}-libs-${postgres_version}-1PGDG.rhel${os_version}.x86_64.rpm"
    )
elif [ "$os_name" == "ubuntu" ]; then
    echo "Placeholder for Ubuntu download links. Please replace this section with appropriate URLs."
else
    echo "Unsupported OS. Please specify either 'rhel' or 'ubuntu'."
    usage
fi

# Install necessary packages
if [ "$os_name" == "rhel" ]; then
    yum install -y wget
elif [ "$os_name" == "ubuntu" ]; then
    apt-get update
    apt-get install -y wget
    apt install -y ca-certificates curl gnupg lsb-release
fi



# Install PostgreSQL packages
if [ "$os_name" == "rhel" ]; then
    # Download PostgreSQL RPM packages
    echo "Downloading PostgreSQL packages..."
    for link in "${download_links[@]}"; do
        wget "$link"
    done
    echo "Installing PostgreSQL packages..."
    yum install -y *.rpm
    # Cleanup: remove downloaded files
    echo "Cleaning up..."
    rm -f postgresql*.rpm
    rpm -qa | grep postgresql
elif [ "$os_name" == "ubuntu" ]; then
    cd /postgresql_packages
    if [ "$os_version" == "20.04" ]; then
        echo "working on 20.04 packages"
        apt install ./postgresql-client-common_256.pgdg20.04+1_all.deb -y
        apt install ./postgresql-common_256.pgdg20.04+1_all.deb -y
        apt install ./libpq5_16.1-1.pgdg20.04+3_amd64.deb -y
        apt install ./postgresql-16_16.1-1.pgdg20.04+1_amd64.deb -y
        apt install ./postgresql-client-16_16.1-1.pgdg20.04+1_amd64.deb -y
    else
        echo "working on ubuntu 22.04 packages"
        # for ubuntu 22 order
        apt install ./libpq5_16.1-1.pgdg22.04+1_amd64.deb -y
        apt install ./libssl1.1_1.1.0g-2ubuntu4_amd64.deb -y
        apt install ./postgresql-client-16_16.1-1.pgdg20.04+1_amd64.deb -y
        apt-get install postgresql-common sysstat -y
    fi
    apt --fix-broken install -y
    dpkg --configure -a
    # rpm -ivh *.deb
    dpkg -l | grep postgresql
    echo "Placeholder for Ubuntu installation steps. Please replace this section with appropriate commands."
fi

echo "PostgreSQL installation completed successfully!"