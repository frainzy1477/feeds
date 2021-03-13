#!/bin/bash -e
set -o pipefail
[ "$DEBUG" == 1 ] && set -x

CUR_DIR=$(pwd)
SDK_DIR=$(pwd)/openwrt-sdk

_update_feeds() {
  if [ ! -f $SDK_DIR/.feeds_updated ]; then
    ./scripts/feeds update base packages luci
    touch $SDK_DIR/.feeds_updated
  fi
}

_install_feeds() {
  _update_feeds
  ./scripts/feeds install "$@"
}

_install_feeds_with_patches() {
  local target_dir="$1"
  local package_name=$(basename "$1")
  _update_feeds
  ./scripts/feeds install $package_name
  cp -rv $CUR_DIR/patch/$package_name/patches $target_dir
}
