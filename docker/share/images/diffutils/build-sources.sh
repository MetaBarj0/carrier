#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf diffutils-3.6.tar.xz
cd diffutils-3.6
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --disable-rpath \
  --disable-nls \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# make this image a package
package
