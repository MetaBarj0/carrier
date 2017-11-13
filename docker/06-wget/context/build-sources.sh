#!/bin/sh

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf wget-1.19.tar.xz
cd wget-1.19
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-threads=posix \
  --with-ssl=gnutls \
  --with-libgnutls-prefix=/usr/local/ \
  CFLAGS='-O3 -s' \
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
