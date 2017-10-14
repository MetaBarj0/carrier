#!/bin/sh
tar -xf expat-2.2.4.tar.bz2
cd expat-2.2.4
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
