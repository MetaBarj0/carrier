#!/bin/sh

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf gmp-6.1.2.tar.xz
cd gmp-6.1.2
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-cxx=yes \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64,-rpath-link,/usr/local/amd64-linux-musl/lib64'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# build and install
make -j $JOBS && make -j $JOBS check && make install

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
