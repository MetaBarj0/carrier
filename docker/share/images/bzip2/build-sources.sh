#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6

PREFIX=/usr/local

# Calculates the optimal job count
JOBS=$(getThreadCount)

make \
  PREFIX=/usr/local \
  CFLAGS='-O3 -s -fPIC' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  -j $JOBS && \

make \
  PREFIX=/usr/local \
  CFLAGS='-O3 -s -fPIC' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  -f Makefile-libbz2_so \
  -j $JOBS && \

make \
  PREFIX=/usr/local \
  install

mv libbz2.so* ${PREFIX}/lib

# make this image a package
package
