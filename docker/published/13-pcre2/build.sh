#!/bin/sh
tar -xf pcre2-10.30.tar.bz2
cd pcre2-10.30
mkdir build && cd build

../configure \
  --prefix=/tmp/install

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

