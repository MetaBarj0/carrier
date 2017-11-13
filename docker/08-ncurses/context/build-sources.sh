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
  --enable-widec \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# get the diff between now and before the project was built, only in the prefix
# directory. Produce a list of added files after the build and installation
docker diff $(hostname) | grep 'A '$PREFIX | sed 's/A\s//' > /image.dist

# import generic functions
. /tmp/functions.sh

# adding dynamic library dependencies
collectSharedObjectDependencies

# intermediate clean
docker image prune -f

# commit changes
docker commit $(hostname) $REPOSITORY
