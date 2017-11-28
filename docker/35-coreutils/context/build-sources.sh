#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf coreutils-8.28.tar.xz
cd coreutils-8.28
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --disable-nls \
  --disable-rpath \
  --enable-threads=posix \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  FORCE_UNSAFE_CONFIGURE=1

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# package this image
package
