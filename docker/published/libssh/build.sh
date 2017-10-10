#!/bin/sh
tar -xf master.tar.gz
cd master
mkdir build && cd build
cmake \
  -DCMAKE_CFLAGS='--sysroot=/usr/local' \
  -DCMAKE_CXXFLAGS='--sysroot=/usr/local' \
  -DCMAKE_BUILD_TYPE='Release' \
  -DCMAKE_INSTALL_PREFIX='/tmp/install' \
  -DWITH_STATIC_LIB=TRUE ..

sed -i.org '4i\\#include <openssl/modes.h>\\' ../src/libcrypto-compat.h

make
