#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf isl-0.18.tar.xz
cd isl-0.18
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install

# make this image a package
package
