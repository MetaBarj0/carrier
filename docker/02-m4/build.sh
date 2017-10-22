#!/bin/sh
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --enable-threads=posix \
  --enable-c++ \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
