#!/bin/bash -e

CUR_DIR=$(pwd)
SDK_DIR=openwrt-sdk-$TARGET

function get_sources() {
  curl -sSL $SDK_URL | tar xfJ -
  mv $(ls -1 | grep $TARGET) $SDK_DIR

  cd $SDK_DIR
  git clone --single-branch -b master https://github.com/openwrt-dev/feeds.git package/custom && cd package/custom
  git submodule update --init --recursive
  cd $CUR_DIR
}

function compile_packages() {
  cd $SDK_DIR

  make defconfig
  make prereq
  make package/libev/compile V=w
  make package/libcares/compile V=w
  make package/libsodium/compile V=w
  make package/mbedtls/compile V=w
  make package/pcre/compile V=w
  make package/luci-app-shadowsocks/compile V=w
  make package/openwrt-dist-luci/compile V=w
  make package/openwrt-chinadns/compile V=w
  make package/openwrt-dns-forwarder/compile V=w

  sed -i "s/CONFIG_PACKAGE_shadowsocks-libev-server=m/# CONFIG_PACKAGE_shadowsocks-libev-server is not set/g" .config
  make package/openwrt-shadowsocks/compile V=w \
    CONFIG_SHADOWSOCKS_STATIC_LINK=y \
    CONFIG_SHADOWSOCKS_WITH_EV=y \
    CONFIG_SHADOWSOCKS_WITH_PCRE=y \
    CONFIG_SHADOWSOCKS_WITH_CARES=y \
    CONFIG_SHADOWSOCKS_WITH_SODIUM=y \
    CONFIG_SHADOWSOCKS_WITH_MBEDTLS=y

  sed -i "s/CONFIG_PACKAGE_simple-obfs-server=m/# CONFIG_PACKAGE_simple-obfs-server is not set/g" .config
  make package/openwrt-simple-obfs/compile V=w \
    CONFIG_SIMPLE_OBFS_STATIC_LINK=y

  ./staging_dir/host/bin/usign -G -s ./key-build -p ./key-build.pub -c "OpenWRT feeds build key"
  make package/index V=s

  cd $CUR_DIR
}

function dist_release() {
  mkdir release
  cp -r $SDK_DIR/bin/packages/*/base release
}

get_sources
compile_packages
dist_release
