#!/bin/sh
tar -xf autoconf-2.69.tar.xz
cd autoconf-2.69
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installation directory
cd /tmp/install
for f in $(find . -type f -exec grep -H '/tmp/install' {} \; | sort | uniq | sed 's/:.*//'); do
  sed -i'' 's/\/tmp\/install/\/usr\/local/g' $f
done
