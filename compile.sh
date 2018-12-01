#!/bin/bash -e

function prepare() {
  curl -kL $SDK_URL > openwrt-sdk.tar.xz
  tar xfJ openwrt-sdk.tar.xz && rm openwrt-sdk.tar.xz
  mv openwrt-sdk-$ARCH-* openwrt-$ARCH

  pushd openwrt-$ARCH
  git clone https://github.com/openwrt-dev/feeds.git package/custom
  pushd package/custom && git submodule update --init --recursive && popd
  popd
}

function compile() {
  pushd openwrt-$ARCH

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

  popd
}

function release() {
  cp -r openwrt-$ARCH/bin/packages/*/base release
}

prepare
compile
release
