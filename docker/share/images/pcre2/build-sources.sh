#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf pcre2-10.30.tar.bz2
cd pcre2-10.30
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# make this image a package
package
