#!/bin/sh
tar -xf diffutils-3.6.tar.xz
cd diffutils-3.6
mkdir build && cd build

CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  ../configure \
    --prefix=/tmp/install \
    --disable-nls \
    --disable-rpath

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
