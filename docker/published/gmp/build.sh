#!/bin/sh
tar -xf gmp-6.1.2.tar.xz
cd gmp-6.1.2
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --enable-cxx=yes \
  --enable-shared=no \
  CC='forward-command.sh gcc' \
  CXX='forward-command.sh g++' \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

make && make check && make install
