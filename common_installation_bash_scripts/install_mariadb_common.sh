#!/bin/bash

# Function to display usage and exit
usage() {
    echo "Usage: $0 <os_type> <os_version> <mariadb_version>"
    echo "Example: $0 rhel 7 11.3.2"
    echo "Example: $0 ubuntu jammy 11.3.2"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    usage
fi

# Set variables from the arguments
os_type="$1"
os_version="$2"
mariadb_version="$3"


# Set the download link based on the OS type and version
if [ "$os_type" == "rhel" ]; then
    download_link="https://downloads.mariadb.com/MariaDB/mariadb-$mariadb_version/yum/rhel/mariadb-$mariadb_version-rhel-$os_version-x86_64-rpms.tar"
elif [ "$os_type" == "ubuntu" ]; then
    download_link="https://downloads.mariadb.com/MariaDB/mariadb-$mariadb_version/repo/ubuntu/mariadb-$mariadb_version-ubuntu-$os_version-amd64-debs.tar"
else
    echo "Unsupported OS type. Use 'rhel' or 'ubuntu'."
    usage
fi

# Common steps
# Set the download link from the command-line argument
download_link="$download_link"

# Install wget if not already installed
if ! command -v wget &> /dev/null; then
    echo "Installing wget..."
    if [ "$os_type" == "rhel" ]; then
        yum install wget -y
    else
        apt-get update
        apt-get install -y wget
    fi
fi

# Download the MariaDB package
echo "Downloading MariaDB package..."
wget "$download_link"

# Extract the tar file
tar_file=$(basename "$download_link")
tar -xvf "$tar_file"

# Navigate to the extracted directory
pkg_dir="${tar_file%.tar}"
cd "$pkg_dir"

# Install MariaDB based on OS type
if [ "$os_type" == "rhel" ]; then
    # Install some required dependencies
    yum install -y boost-atomic boost-chrono boost-date-time boost-filesystem boost-program-options boost-regex boost-system boost-thread galera libicu libtool-ltdl libzstd lsof lzo make net-tools openssl perl-Compress-Raw-Bzip2 perl-Compress-Raw-Zlib perl-DBI perl-IO-Compress perl-Net-Daemon perl-PlRPC rsync snappy socat tcp_wrappers-libs unixODBC epel-release jemalloc Judy pv

    # Install MariaDB RPM packages, skipping broken dependencies
    echo "Installing MariaDB RPM packages..."
    # yum install *.rpm --skip-broken -y
    yum install galera*.rpm -y
    yum install *x86_64.rpm -y
    mariadb --version
elif [ "$os_type" == "ubuntu" ]; then
    # Install required packages
    # apt-get update
    # apt install -y ca-certificates curl gnupg lsb-release
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
    # apt-get install -y fontconfig-config fonts-dejavu-core gawk libboost-program-options1.74.0 libbrotli1 libbsd0 libc-dev-bin libc-devtools libc6-dev libcrypt-dev libdaxctl1 libdeflate0 libedit2 libexpat1 libfontconfig1 libfreetype6 libgd3 libjbig0 libjpeg-turbo8 libjpeg8 libkmod2 libmd0 libmpfr6 libndctl6 libnsl-dev libpmem1 libpng16-16 libreadline8 libsigsegv2 libssl-dev libtiff5 libtirpc-dev liburing2 libwebp7 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxpm4 linux-libc-dev manpages manpages-dev psmisc readline-common rpcsvc-proto ucf zlib1g-dev binutils binutils-common binutils-x86-64-linux-gnu cracklib-runtime file iproute2 libatm1 libbinutils libboost-atomic1.74.0 libboost-chrono1.74.0 libboost-date-time1.74.0 libboost-filesystem1.74.0 libboost-regex1.74.0 libboost-system1.74.0 libboost-thread1.74.0 libbpf0 libcap2-bin libconfig-inifiles-perl libcrack2 libctf-nobfd0 libctf0 libcurl4 libdbi-perl libelf1 libgdbm-compat4 libgdbm6 libgflags2.2 libicu70 libjemalloc2 libjudydebian1 libldap-2.5-0 libldap-common libltdl7 liblzo2-2 libmagic-mgc libmagic1 libmecab2 libmnl0 libmpdec3 libnghttp2-14 libodbc2 libodbcinst2 libpam-cap libperl5.34 libpopt0 libpython3-stdlib libpython3.10-minimal libpython3.10-stdlib librtmp1 libsasl2-2 libsasl2-modules libsasl2-modules-db libsnappy1v5 libsqlite3-0 libssh-4 libwrap0 libxml2 libxtables12 lsof media-types net-tools netbase perl perl-modules-5.34 python3 python3-minimal python3.10 python3.10-minimal rocksdb-tools rsync socat unixodbc unixodbc-common wamerican

    # Install MariaDB DEB packages
    echo "Installing MariaDB DEB packages..."
    # removing column store campi since the systemctl is causing the error and systecmctl does not work in docker
    # rm -rf mariadb-columnstore-cmapi*.deb
    apt install ./*.deb -y
    apt --fix-broken install -y
    mariadb --version
fi

# Cleanup: remove downloaded files and extracted directory
# echo "Cleaning up..."
# cd ..
# rm -f "$tar_file"
# rm -rf "$pkg_dir"

echo "MariaDB installation completed successfully!"
