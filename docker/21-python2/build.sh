#!/bin/sh
tar -xf Python-2.7.14.tar.xz

# copy the custome setup file to enable ssl support
cp -f Setup.dist Python-2.7.14/Modules/

cd Python-2.7.14
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --enable-shared \
  --enable-optimizations \
  --with-lto \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
