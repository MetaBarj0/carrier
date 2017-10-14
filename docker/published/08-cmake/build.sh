#!/bin/sh
tar -xf cmake-3.10.0-rc1.tar.gz
cd cmake-3.10.0-rc1
mkdir build && cd build

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# forward-command script calls don't work because of multi arguments call
export CFLAGS='-O3 -s'
export CXXFLAGS='-O3 -s'
export LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

../bootstrap \
  --prefix=/tmp/install \
  --parallel=$JOBS

make -j $JOBS && make -j $JOBS install
