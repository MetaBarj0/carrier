#!/bin/sh
tar -xf openssh-7.6p1.tar.gz
cd openssh-7.6p1
mkdir build && cd build

../configure \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  --prefix=/tmp/install

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
