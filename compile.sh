#!/bin/bash -e

function prepare() {
  SDK_DIR=openwrt-sdk-$ARCH

  curl -kLs $SDK_URL | tar xfJ -
  mv $(ls | sort | grep openwrt) $SDK_DIR

  pushd $SDK_DIR
  git clone https://github.com/openwrt-dev/feeds.git --single-branch package/custom
  pushd package/custom && git submodule update --init --recursive && popd
  popd
}

function compile() {
  pushd $SDK_DIR

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

  popd
}

function release() {
  mkdir release
  cp -r $SDK_DIR/bin/packages/*/base release
}

prepare
compile
release
