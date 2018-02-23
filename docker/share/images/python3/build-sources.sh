#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf Python-3.6.3.tar.xz

# copy the custom setup file to enable ssl support
cp -f Setup Python-3.6.3/Modules/

cd Python-3.6.3
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-shared \
  --enable-optimizations \
  --with-lto \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install

# remove all compiled python files
find /usr/local/lib/python3.6 -type f -name '*.pyc' -delete

# make this image a package
package
