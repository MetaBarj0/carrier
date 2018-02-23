#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf less-487.tar.gz
cd less-487
mkdir build && cd build

PREFIX=/usr/local

CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  ../configure --prefix=$PREFIX

# TODO use getThreadCount as here for all images
# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install

# make this image a package
packageIncluding /usr/local/share/terminfo
