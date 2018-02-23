#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf readline-7.0.tar.gz
cd readline-7.0

mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --with-curses \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib,-rpath-link,/usr/local/lib,-lncurses'

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install

# make this image a package
packageIncluding /usr/local/share/terminfo
