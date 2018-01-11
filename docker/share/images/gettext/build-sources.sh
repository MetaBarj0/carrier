#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --disable-java \
  --disable-native-java \
  --enable-threads=posix \
  --disable-rpath \
  --disable-openmp \
  --enable-relocatable \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# make this image a package
packageIncluding ${PREFIX}/share/terminfo
