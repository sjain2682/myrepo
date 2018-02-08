#!/bin/bash

cd /tmp

# Install required packages
#
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade
apt-get -y install libunwind8 libnuma1 libjemalloc1 libc++1 gdb libcurl3 openssl python python3 libgssapi-krb5-2 libsss-nss-idmap0 wget apt-transport-https locales gawk sed lsof pbzip2 curl software-properties-common

# Configure UTF-8 locale
#
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Install packages.microsoft.com repository configuration
#
wget http://packages.microsoft.com/ubuntu/16.04/prod/pool/main/p/packages-microsoft-prod/packages-microsoft-prod_1.0-1-xenial.deb
dpkg -i packages-microsoft-prod_1.0-1-xenial.deb

# Install mssql-tools package
#
apt-get update
ACCEPT_EULA=Y apt-get -y --no-install-recommends install mssql-tools

# Download and expand mssql server
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
add-apt-repository "$(curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list)"
apt-get update
apt-get download mssql-server
MSSQL_DEB_FILE=`ls mssql-server*deb`
dpkg -x $MSSQL_DEB_FILE /

# Remove files from /tmp
#
rm -rf /tmp/*

# Remove files from apt cache
#
apt-get clean
rm -rf /var/lib/apt/lists/*
