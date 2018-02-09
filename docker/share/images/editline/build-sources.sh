#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf libedit-20170329-3.1.tar.gz
cd libedit-20170329-3.1
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-lreadline' \
  CPPFLAGS='-I /usr/local/include/ncurses'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# make this image a package
packageIncluding /usr/local/share/terminfo
