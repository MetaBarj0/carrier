#!/bin/sh

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-threads=posix \
  --enable-c++ \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# build and install
make -j $JOBS && make install

# import generic functions
. /tmp/functions.sh

# register built file for packaging
registerBuiltFilesForPackaging

# adding dynamic library dependencies
collectSharedObjectDependencies

# finalize the packaging
package
