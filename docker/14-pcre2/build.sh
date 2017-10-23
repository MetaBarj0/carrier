#!/bin/sh
tar -xf pcre2-10.30.tar.bz2
cd pcre2-10.30
mkdir build && cd build

../configure \
  --prefix=/tmp/install

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;

# fix prefix in pkgconfig files
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/libpcre2-8.pc
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/libpcre2-posix.pc
