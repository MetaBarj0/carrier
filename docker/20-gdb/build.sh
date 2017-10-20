#!/bin/sh
tar -xf gdb-8.0.1.tar.xz
cd gdb-8.0.1
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --enable-gold=yes \
  --enable-ld=yes \
  --enable-lto \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
