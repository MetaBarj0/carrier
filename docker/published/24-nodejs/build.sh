#!/bin/sh
tar -xf node-v8.7.0.tar.gz
cd node-v8.7.0
# mkdir build && cd build

CC=gcc \
CXX=g++ \
CFLAGS='-O3 -s' \
CXXFLAGS='-O3 -s' \
  ./configure \
    --prefix=/tmp/install \
    --dest-cpu=x64 \
    --dest-os=linux \
    --with-intl=none \
    --fully-static

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# the shabang is not cool in npm and npx
sed -i'' 's/#!.*/#!\/usr\/local\/bin\/node/' /tmp/install/lib/node_modules/npm/bin/npm-cli.js
sed -i'' 's/#!.*/#!\/usr\/local\/bin\/node/' /tmp/install/lib/node_modules/npm/bin/npx-cli.js

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
