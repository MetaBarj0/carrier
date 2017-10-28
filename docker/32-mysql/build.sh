#!/bin/sh
tar -xf mysql-5.6.38.tar.gz

# deploy patches
tar --directory mysql-5.6.38 -xf patch.tar

cd mysql-5.6.38
mkdir build && cd build

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS_RELEASE='-O3 -s -DNDEBUG' \
  -DCMAKE_CXX_COMPILER=/usr/local/bin/g++ \
  -DCMAKE_CXX_FLAGS_RELEASE='-O3 -s -DNDEBUG' \
  -DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/ \
  -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/ \
  -DWITH_PIC=ON \
  -DWITH_SSL=system \
  -DWITH_ZLIB=system \
  ..

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
