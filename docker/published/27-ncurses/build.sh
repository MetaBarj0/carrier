#!/bin/sh
tar -xf ncurses-6.0.tar.gz
cd ncurses-6.0
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --with-shared \
  --with-cxx-shared \
  --with-pthread \
  --enable-weak-symbols \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
