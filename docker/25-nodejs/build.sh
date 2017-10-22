#!/bin/sh
tar -xf node-v8.7.0.tar.gz
cd node-v8.7.0

CC=gcc \
CXX=g++ \
CFLAGS='-O3 -s' \
CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/' \
  ./configure \
    --prefix=/tmp/install \
    --dest-cpu=x64 \
    --dest-os=linux \
    --with-intl=system-icu

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# the shabang is not cool in npm and npx
sed -i'' 's/#!.*/#!\/usr\/local\/bin\/node/' /tmp/install/lib/node_modules/npm/bin/npm-cli.js
sed -i'' 's/#!.*/#!\/usr\/local\/bin\/node/' /tmp/install/lib/node_modules/npm/bin/npx-cli.js
