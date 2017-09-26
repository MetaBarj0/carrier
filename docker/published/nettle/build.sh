#!/bin/sh
tar -xf nettle-3.3.tar.gz
cd nettle-3.3
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --disable-shared \
  CC='forward-command.sh gcc' CXX='forward-command.sh g++' \
  CFLAGS='-O3 -s' CXXFLAGS='-O3 -s'

make && make install
