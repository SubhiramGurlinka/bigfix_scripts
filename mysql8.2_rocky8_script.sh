#!/usr/bin/env bash

# Install necessary packages
yum install -y wget sudo perl libaio numactl net-tools

# Download MySQL RPM bundle
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-8.2.0-1.el8.x86_64.rpm-bundle.tar

# Extract and install MySQL RPMs
tar -xvf mysql-8.2.0-1.el8.x86_64.rpm-bundle.tar

rpm -ivh mysql-community-icu-data-files-8.2.0-1.el8.x86_64.rpm
rpm -ivh mysql-community-common-8.2.0-1.el8.x86_64.rpm
rpm -ivh mysql-community-client-plugins-8.2.0-1.el8.x86_64.rpm
rpm -ivh mysql-community-libs-8.2.0-1.el8.x86_64.rpm
rpm -ivh mysql-community-client-8.2.0-1.el8.x86_64.rpm
rpm -ivh mysql-community-server-8.2.0-1.el8.x86_64.rpm

# Clean up
rm -f mysql-8.2.0-1.el8.x86_64.rpm-bundle.tar
