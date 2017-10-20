#!/bin/sh
tar -xf wget-1.19.tar.xz
cd wget-1.19
mkdir build && cd build
../configure \
  --prefix=/tmp/install \
  --enable-threads=posix \
  --with-ssl=gnutls \
  --with-libgnutls-prefix=/usr/local/ \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
