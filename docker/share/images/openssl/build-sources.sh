#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf openssl-1.0.2n.tar.gz
cd openssl-1.0.2n

PREFIX=/usr/local

CFLAGS='-O3 -s -fPIC -Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/' \
  ./config \
    shared zlib \
    --prefix=$PREFIX \
    --openssldir=${PREFIX}/ssl

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make test && make install

# remove an unneeded perl script
rm ${PREFIX}/bin/c_rehash

# make this image a package
package
