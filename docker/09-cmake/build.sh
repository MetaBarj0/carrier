#!/bin/sh
tar -xf cmake-3.10.0-rc1.tar.gz
cd cmake-3.10.0-rc1
mkdir build && cd build

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# bootstrap script variables
export CFLAGS='-O3 -s'
export CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'
export LDFLAGS='-Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

../bootstrap \
  --prefix=/tmp/install \
  --parallel=$JOBS

make -j $JOBS && make -j $JOBS install
