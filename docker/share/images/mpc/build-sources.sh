#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf mpc-1.0.3.tar.gz
cd mpc-1.0.3
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-gold=yes \
  --enable-ld=yes \
  --enable-lto \
  --with-mpfr=/usr/local/ \
  --with-gmp=/usr/local/ \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# make this image a package
package
