#!/bin/sh
tar -xf openssl-1.0.2l.tar.gz
cd openssl-1.0.2l

./config --prefix=/tmp/install --openssldir=/usr/local/ssl no-shared zlib -O3 -s --sysroot=/usr/local
make && make test && make install
