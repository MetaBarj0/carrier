#!/bin/sh
tar -xf gmp-6.1.2.tar.xz
cd gmp-6.1.2
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --enable-cxx=yes \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64,-rpath-link,/usr/local/amd64-linux-musl/lib64'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make -j $JOBS check && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
