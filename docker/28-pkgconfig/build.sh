#!/bin/sh
tar -xf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --with-internal-glib \
  CFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
