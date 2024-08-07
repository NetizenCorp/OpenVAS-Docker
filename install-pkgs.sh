#!/bin/bash

apt-get update
apt-get upgrade -y

INSTALL_PKGS="
autossh \
bison \
build-essential \
ca-certificates \
cmake \
curl \
cron \
gcc \
gcc-mingw-w64 \
git \
geoip-database \
gnutls-bin \
gnupg \
heimdal-dev \
ike-scan \
python3-impacket \
libgcrypt20-dev \
libjson-glib-dev \
libglib2.0-dev \
libgnutls28-dev \
libgpgme11-dev \
libgpgme-dev \
libhiredis-dev \
libical-dev \
libksba-dev \
libldap2-dev \
libcap2-bin \
libmicrohttpd-dev \
libnet1-dev \
libnet-snmp-perl \
libpcap-dev \
libpopt-dev \
libsnmp-dev \
libssh-gcrypt-dev \
libbsd-dev \
libunistring-dev \
libxml2-dev \
libpaho-mqtt-dev \
libcurl4-gnutls-dev \
mosquitto \
nano \
net-tools \
nmap \
openssh-client \
perl-base \
python3-bcrypt \
python3-cffi \
python3-cryptography \
python3-defusedxml \
python3-lxml \
python3-gnupg \
python3-packaging \
python3-paramiko \
python3-pip \
python3-psutil \
python3-pycparser \
python3-pyparsing \
python3-redis \
python3-setuptools \
python3-six \
python3-venv \
python3-paho-mqtt \
redis-server \
redis-tools \
rsync \
sudo \
smbclient \
uuid-dev \
vim \
wapiti \
wget"

echo $INSTALL_PKGS

apt-get install -y --no-install-recommends $INSTALL_PKGS

rm -rf /var/lib/apt/lists/*
