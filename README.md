# Feeds

[![Build Status](https://travis-ci.org/openwrt-dev/feeds.svg?branch=master)](https://travis-ci.org/openwrt-dev/feeds)

```bash
apt-get install gcc g++ make automake autoconf libtool git \
    ccache file patch curl quilt gawk fakeroot gettext bzip2 \
    python zlib1g-dev libncurses5-dev unzip xz-utils --no-install-recommends

git clone https://github.com/openwrt-dev/feeds.git
cd feeds
git submodule update --init --recursive
git submodule update --remote --merge

make defconfig
make prereq
# ...
# See .travis.yml
```

### Upstreams

- [mbedtls](https://github.com/shadowsocks/openwrt-feeds/tree/master/base/mbedtls)
- [pcre](https://github.com/shadowsocks/openwrt-feeds/tree/master/packages/pcre)
- [libev](https://github.com/shadowsocks/openwrt-feeds/tree/master/packages/libev)
- ~~[libcares](https://github.com/openwrt/packages/tree/master/libs/c-ares)~~
- [libcares](https://github.com/shadowsocks/openwrt-feeds/tree/master/packages/libcares)
- ~~[libsodium](https://github.com/openwrt/packages/tree/master/libs/libsodium)~~
- [libsodium](https://github.com/shadowsocks/openwrt-feeds/tree/master/packages/libsodium)

### Reference

> https://github.com/simonsmh/lede-dist
