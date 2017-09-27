#!/bin/sh
tar -xf nettle-2.5.tar.gz
cd nettle-2.5
mkdir build && cd build
../configure \
  --prefix=/tmp/install \
  --disable-assembler \
  --disable-shared \
  CC='forward-command.sh gcc' \
  CXX='forward-command.sh g++' \
  CFLAGS='-O3 -s'
  CXXFLAGS='-O3 -s'

make && make install
