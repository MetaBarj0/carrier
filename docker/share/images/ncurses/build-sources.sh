#!/bin/sh

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf ncurses-6.0.tar.gz
cd ncurses-6.0
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --without-ada \
  --disable-termcap \
  --disable-rpath-hack \
  --with-shared \
  --without-cxx-binding \
  --with-pthread \
  --enable-weak-symbols \
  --with-terminfo-dirs="/etc/terminfo:${PREFIX}/share/terminfo" \
  --enable-pc-files \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(getThreadCount)

make -j $JOBS && make install

# make this image a package
package
