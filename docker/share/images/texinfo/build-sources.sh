#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf texinfo-6.5.tar.xz
cd texinfo-6.5
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  CFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install && make TEXMF=$PREFIX install-tex

# make this image a package
packageIncluding metabarj0/perl
