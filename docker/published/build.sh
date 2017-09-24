#!/bin/sh
cd /tmp
tar -xf ucl-1.03.tar.gz
cd ucl-1.03
mkdir build
cd build
../configure --prefix=/tmp/install CC='forward-command.sh gcc' CXX='forward-command.sh g++' CFLAGS='-O3 -s -std=gnu90' CXXFLAGS='-O3 -s'
make && make install
