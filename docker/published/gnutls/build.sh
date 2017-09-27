#!/bin/sh
tar -xf gnutls-3.1.5.tar.xz
cd gnutls-3.1.5
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --disable-assembler \
  --enable-shared=no \
  CC='forward-command.sh gcc' CXX='forward-command.sh g++' \
  CFLAGS='-O3 -s' CXXFLAGS='-O3 -s'

make && make install
