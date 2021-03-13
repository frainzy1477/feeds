#!/bin/bash -e

. $(dirname "$0")/func.sh

download_sdk() {
  curl -sSL $SDK_URL | tar Jxf -
  mv openwrt-sdk-* $SDK_DIR
}

get_sources() {
  cd $SDK_DIR

  # fullconenat
  _install_feeds_with_patches package/feeds/base/firewall/
  _install_feeds_with_patches package/feeds/luci/luci-app-firewall/

  # install package depends
  _install_feeds_with_patches package/feeds/base/mbedtls/
  _install_feeds c-ares libev libsodium pcre

  # copy sources
  cp -rv $CUR_DIR/net/* package/
  cp $CUR_DIR/key-build .

  cd $CUR_DIR
}

build_packages() {
  cd $SDK_DIR

  make defconfig

  make -j$(nproc) package/openwrt-chinadns/compile V=w
  make -j$(nproc) package/openwrt-chinadns-ng/compile V=w
  make -j$(nproc) package/openwrt-dns-forwarder/compile V=w
  make -j$(nproc) package/openwrt-dns2tcp/compile V=w
  make -j$(nproc) package/openwrt-hev-socks5-server/compile V=w
  make -j$(nproc) package/openwrt-ipt2socks/compile V=w
  make -j$(nproc) package/openwrt-portfwd/compile V=w
  make -j$(nproc) package/openwrt-shadowsocks/compile V=w
  make -j$(nproc) package/openwrt-simple-obfs/compile V=w
  make -j$(nproc) package/openwrt-udp2raw/compile V=w
  make -j$(nproc) package/openwrt-udpspeeder/compile V=w
  make -j$(nproc) package/openwrt-vlmcsd/compile V=w
  make -j$(nproc) package/luci-app-shadowsocks/compile V=w
  make -j$(nproc) package/openwrt-dist-luci/compile V=w

  make -j$(nproc) package/openwrt-fullconenat/compile V=w
  make -j$(nproc) package/firewall/compile V=w
  make -j$(nproc) package/luci-app-firewall/compile V=w

  # remove useless & create index
  find bin/ -type f $(printf " ! -name %s_*" $(cat $CUR_DIR/packages.txt)) | xargs rm -f
  make package/index V=s

  cd $CUR_DIR
}

copy_packages() {
  cp -rv $SDK_DIR/bin/packages/*/base $IPK_ARCH-base
  cp -rv $SDK_DIR/bin/packages/*/packages $IPK_ARCH-packages
  cp -rv $SDK_DIR/bin/packages/*/luci $IPK_ARCH-luci
  cp -rv $SDK_DIR/bin/targets/${IPK_ARCH%%-*}/${IPK_ARCH##*-}/packages $IPK_ARCH-core
}

download_sdk
get_sources
build_packages
copy_packages
