#!/bin/bash
#
# usage:
# single line command:
# curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mariadb_ubuntu_script.sh; bash install_mariadb_ubuntu_script.sh "https://downloads.mariadb.com/MariaDB/mariadb-10.11.1/repo/ubuntu/mariadb-10.11.1-ubuntu-jammy-amd64-debs.tar"
# usage:
# curl -O https://raw.githubusercontent.com/SubhiramGurlinka/bigfix_scripts/main/install_mariadb_ubuntu_script.sh
# bash install_mariadb_ubuntu_script.sh "https://downloads.mariadb.com/MariaDB/mariadb-10.11.1/repo/ubuntu/mariadb-10.11.1-ubuntu-jammy-amd64-debs.tar"
# Replace the MariaDB download link in the examples with the appropriate link for the version you want to install. Ensure the link points to a valid MariaDB DEB package for the desired Ubuntu version.

#!/bin/bash

# Check if the download URL is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <mariadb_download_url>"
    exit 1
fi

# Install required packages
apt-get update
apt-get install -y \
fontconfig-config fonts-dejavu-core gawk libboost-program-options1.74.0 libbrotli1 libbsd0 libc-dev-bin libc-devtools libc6-dev libcrypt-dev libdaxctl1 libdeflate0 libedit2 libexpat1 libfontconfig1 \
libfreetype6 libgd3 libjbig0 libjpeg-turbo8 libjpeg8 libkmod2 libmd0 libmpfr6 libndctl6 libnsl-dev libpmem1 libpng16-16 libreadline8 libsigsegv2 libssl-dev libtiff5 libtirpc-dev liburing2 libwebp7 \
libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxpm4 linux-libc-dev manpages manpages-dev psmisc readline-common rpcsvc-proto ucf zlib1g-dev \
binutils binutils-common binutils-x86-64-linux-gnu cracklib-runtime file iproute2 libatm1 libbinutils libboost-atomic1.74.0 libboost-chrono1.74.0 libboost-date-time1.74.0 libboost-filesystem1.74.0 \
libboost-regex1.74.0 libboost-system1.74.0 libboost-thread1.74.0 libbpf0 libcap2-bin libconfig-inifiles-perl libcrack2 libctf-nobfd0 libctf0 libcurl4 libdbi-perl libelf1 libgdbm-compat4 libgdbm6 \
libgflags2.2 libicu70 libjemalloc2 libjudydebian1 libldap-2.5-0 libldap-common libltdl7 liblzo2-2 libmagic-mgc libmagic1 libmecab2 libmnl0 libmpdec3 libnghttp2-14 libodbc2 libodbcinst2 libpam-cap \
libperl5.34 libpopt0 libpython3-stdlib libpython3.10-minimal libpython3.10-stdlib librtmp1 libsasl2-2 libsasl2-modules libsasl2-modules-db libsnappy1v5 libsqlite3-0 libssh-4 libwrap0 libxml2 \
libxtables12 lsof media-types net-tools netbase perl perl-modules-5.34 python3 python3-minimal python3.10 python3.10-minimal rocksdb-tools rsync socat unixodbc unixodbc-common wamerican

# Download and install MariaDB
wget "$1" -O mariadb-debs.tar
tar -xvf mariadb-debs.tar
cd mariadb-*-ubuntu-*-debs
dpkg -i *deb
dpkg -i *deb

# Clean up
cd ..
rm -rf mariadb-*-ubuntu-*-debs mariadb-debs.tar

echo "Installation completed successfully!"
