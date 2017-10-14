#!/bin/sh
tar -xf gnutls-3.1.5.tar.xz
cd gnutls-3.1.5
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
