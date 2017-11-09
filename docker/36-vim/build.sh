#!/bin/sh
tar -xf master.tar.gz
cd vim-master

CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  ./configure \
    --prefix=/tmp/install \
    --enable-pythoninterp=dynamic \
    --enable-gui=no \
    --disable-nls \
    --without-x \
    --enable-multibyte \
    --with-compiledby='metabarj0'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install
