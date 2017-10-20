#!/bin/sh
tar -xf nettle-2.5.tar.gz
cd nettle-2.5
mkdir build && cd build
../configure \
  --prefix=/tmp/install \
  CFLAGS='-O3 -s -static'
  CXXFLAGS='-O3 -s -static'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
