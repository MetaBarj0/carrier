#!/bin/sh
tar -xf ucl-1.03.tar.gz
cd ucl-1.03

mkdir build
cd build

../configure \
  --prefix=/tmp/install \
  CFLAGS='-O3 -s -std=gnu90' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
