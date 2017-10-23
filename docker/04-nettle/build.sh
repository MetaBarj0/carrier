#!/bin/sh
tar -xf nettle-2.5.tar.gz
cd nettle-2.5
mkdir build && cd build
../configure \
  --prefix=/tmp/install \
  CFLAGS='-O3 -s'
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;

# fix prefix in pkgconfig files
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/hogweed.pc
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/nettle.pc
