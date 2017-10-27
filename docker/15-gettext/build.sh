#!/bin/sh
tar -xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --disable-java \
  --disable-native-java \
  --enable-threads=posix \
  --disable-rpath \
  --disable-openmp \
  --enable-relocatable \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
