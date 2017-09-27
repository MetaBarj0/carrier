#!/bin/sh
tar -xf wget-1.19.tar.xz
cd wget-1.19
mkdir build && cd build
../configure \
  --prefix=/tmp/install \
  --enable-threads=posix \
  --with-ssl=gnutls \
  --with-libgnutls-prefix=/usr/local \
  CC='forward-command.sh gcc' \
  CFLAGS='-O3 -s'

make && make install
