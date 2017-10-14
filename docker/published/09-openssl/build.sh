#!/bin/sh
tar -xf openssl-1.0.2l.tar.gz
cd openssl-1.0.2l

./config \
  --prefix=/tmp/install \
  --openssldir=/usr/local/ssl \
  shared zlib \
  -O3 -s \
  -Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make test && make install

# remove an unneeded perl script
rm /tmp/install/bin/c_rehash
