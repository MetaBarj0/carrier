#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf sed-4.4.tar.xz
cd sed-4.4
mkdir build && cd build

PREFIX=/usr/local

FORCE_UNSAFE_CONFIGURE=1 \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  ../configure \
    --prefix=$PREFIX \
    --disable-rpath

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install

# make this image a package
package
