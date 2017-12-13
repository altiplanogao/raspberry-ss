#!/bin/bash

export LIBSODIUM_VER=1.0.13
export MBEDTLS_VER=2.6.0
export SHADOWSOCKS_LIBEV_VER=3.1.1
export SHADOWSOCKS_CHINADNS_VER=1.3.2

function install_libsodium(){
  # Installation of Libsodium
  sudo apt-get purge -y libsodium-dev
  wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
  tar xvf libsodium-$LIBSODIUM_VER.tar.gz
  pushd libsodium-$LIBSODIUM_VER
    ./configure --prefix=/usr && make
    sudo make install
  popd
  sudo ldconfig
}

function install_mbedtls(){
  # Installation of MbedTLS
  wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
  tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
  pushd mbedtls-$MBEDTLS_VER
    make SHARED=1 CFLAGS=-fPIC
    sudo make DESTDIR=/usr install
  popd
  sudo ldconfig
}

function install_shadowsocks_libev(){
  # Start building
  rm -rf shadowsocks-libev
  git clone https://github.com/shadowsocks/shadowsocks-libev.git
  pushd shadowsocks-libev
    git submodule update --init --recursive
    git checkout v${SHADOWSOCKS_LIBEV_VER}
    ./autogen.sh && ./configure && make
    sudo make install
  popd
}

function install_chinadns(){
  # ChinaDNS
  rm -rf ChinaDNS
  git clone https://github.com/shadowsocks/ChinaDNS.git
  pushd ChinaDNS
    git checkout ${SHADOWSOCKS_CHINADNS_VER}
    ./autogen.sh && ./configure && make
    cp -af src/chinadns /usr/local/bin/chinadns
    sudo mkdir /etc/shadowsocks
    sudo cp -af iplist.txt /etc/shadowsocks/ip_blacklist
  popd
}

# Installation of basic build dependencies
## Debian / Ubuntu
sudo apt-get install --no-install-recommends -y gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake libmbedtls-dev libsodium-dev
## CentOS / Fedora / RHEL
# sudo yum install gettext gcc autoconf libtool automake make asciidoc xmlto c-ares-devel libev-devel
## Arch
# sudo pacman -S gettext gcc autoconf libtool automake make asciidoc xmlto c-ares libev
sudo apt-get install -y iptables-persistent

mkdir workdir
pushd workdir

# install_libsodium
# install_mbedtls
# install_shadowsocks_libev
  sudo apt-get install -y ipset 

  install_chinadns

popd
