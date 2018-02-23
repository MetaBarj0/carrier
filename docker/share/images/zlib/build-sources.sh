#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf zlib-1.2.11.tar.xz
cd zlib-1.2.11
mkdir build && cd build

PREFIX=/usr/local

CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  ../configure --prefix=$PREFIX

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install

# make this image a package
package
