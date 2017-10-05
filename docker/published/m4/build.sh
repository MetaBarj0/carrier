#!/bin/sh
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --enable-threads=posix \
  --enable-c++ \
  CC='forward-command.sh gcc' \
  CXX='forward-command.sh g++' \
  CFLAGS='-O3 -s -static' \
  CXXFLAGS='-O3 -s -static'
make && make install
