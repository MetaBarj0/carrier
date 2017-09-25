#!/bin/sh
tar -xf cmake-3.9.3.tar.gz
cd cmake-3.9.3
mkdir build && cd build

# forward-command script calls don't work because of multi arguments call
CC=/usr/local/bin/amd64-linux-musl-gcc \
CXX=/usr/local/bin/amd64-linux-musl-g++ \
CFLAGS='--sysroot=/usr/local -O3 -s' \
CXXFLAGS='--sysroot=/usr/local -I/usr/local/include/c++/7.2.0 -I/usr/local/include/c++/7.2.0/amd64-linux-musl -O3 -s' \
../bootstrap --prefix=/tmp/install
make && make install
