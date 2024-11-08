#!/bin/bash

# Usage:
# bash install_mysql.sh <os_type> <os_version> <mysql_version>
# os_type: "rhel" or "ubuntu"
# os_version: For RHEL: major version like 8 or 9. For Ubuntu: "20.04" or "22.04"
# mysql_version: MySQL version like 8.0.37

if [ $# -ne 3 ]; then
    echo "Usage: $0 <os_type> <os_version> <mysql_version>"
    exit 1
fi

os_type=$1
os_version=$2
mysql_version=$3

install_mysql_rhel() {
    # Construct the download link
    download_link="https://downloads.mysql.com/archives/get/p/23/file/mysql-${mysql_version}-1.el${os_version}.x86_64.rpm-bundle.tar"

    # Validate OS version in the download link
    if ! [[ "$download_link" =~ el${os_version} ]]; then
        echo "Error: The download link OS version does not match the provided OS version."
        exit 1
    fi

    # Extract filename from download link
    filename=$(basename "$download_link")

    # Install necessary packages
    yum install -y wget sudo perl libaio numactl net-tools openssl-devel openssl-libs libtirpc libcrypto.so.1.1 perl-JSON

    # Download MySQL RPM bundle
    wget "$download_link"

    # Extract and install MySQL RPMs
    tar -xvf "$filename"

    # Install MySQL RPMs
    # rpm -ivh mysql-community-icu-data-files-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-common-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-client-plugins-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-libs-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-client-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-server-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-debuginfo-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-client-debuginfo-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-client-plugins-debuginfo-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-debugsource-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-devel-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-libs-debuginfo-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-server-debug-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-server-debug-debuginfo-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-server-debuginfo-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-test-${MYSQL_VERSION}*.rpm
    # rpm -ivh mysql-community-test-debuginfo-${MYSQL_VERSION}*.rpm
    yum install -y mysql-*.rpm

    # Clean up
    rm -f "$filename"

    # Show installed MySQL version
    mysql --version
}

install_mysql_ubuntu() {
    # Construct the download link
    download_link="https://downloads.mysql.com/archives/get/p/23/file/mysql-server_${mysql_version}-1ubuntu${os_version}_amd64.deb-bundle.tar"

    # Validate OS version in the download link
    if ! [[ "$download_link" =~ ubuntu${os_version} ]]; then
        echo "Error: The download link OS version does not match the provided OS version."
        exit 1
    fi

    # Extract filename from download link
    filename=$(basename "$download_link")

    # Set DEBIAN_FRONTEND to noninteractive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive

    # Install necessary packages
    apt-get update
    apt-get install -y wget sudo perl libaio1 libmecab2 libnuma1 psmisc libmysqlclient-dev libjson-perl mecab-ipadic-utf8 libsasl2-2 libgssapi-krb5-2 libkrb5-3

    # Download MySQL DEB bundle
    wget "$download_link"

    # Extract MySQL DEB files
    tar -xvf "$filename"

    # Install MySQL DEB files
    # dpkg -i mysql-common*.deb
    # dpkg -i mysql-community-client-plugins*.deb
    # dpkg -i mysql-community-client-core*.deb
    # dpkg -i mysql-community-client*.deb
    # dpkg -i mysql-community-server-core*.deb
    # dpkg -i mysql-client*.deb
    # dpkg -i mysql-community-server*.deb
    # dpkg -i mysql-community-test*.deb
    # dpkg -i mysql-community-test-debug*.deb
    apt install ./mysql*.deb -y

    dpkg --configure -a

    # Clean up
    rm -f "$filename"

    # Show installed MySQL version
    mysql --version
}

# Main installation logic
case $os_type in
    rhel)
        install_mysql_rhel
        ;;
    ubuntu)
        install_mysql_ubuntu
        ;;
    *)
        echo "Unsupported OS type. Please use 'rhel' or 'ubuntu'."
        exit 1
        ;;
esac

#echo "Restarting the bigfix client"

#restart_bes_client