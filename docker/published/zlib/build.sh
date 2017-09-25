#!/bin/sh
tar -xf zlib-1.2.11.tar.xz
cd zlib-1.2.11
mkdir build && cd build
CC='forward-command.sh gcc' CFLAGS='-O3 -s' ../configure --static --prefix=/tmp/install
make install
