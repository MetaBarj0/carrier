#!/bin/sh

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf gnutls-3.1.5.tar.xz
cd gnutls-3.1.5
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# build and install
make -j $JOBS && make install

# get the diff between now and before the project was built, only in the prefix
# directory. Produce a list of added files after the build and installation
docker diff $(hostname) | grep 'A '$PREFIX | sed 's/A\s//' > /image.dist

# import generic functions
. /tmp/functions.sh

# adding dynamic library dependencies
collectSharedObjectDependencies

# finally, adding the dynamic loader directory
echo '/lib' >> /image.dist

# intermediate clean
docker image prune -f

# commit changes
docker commit $(hostname) $REPOSITORY
