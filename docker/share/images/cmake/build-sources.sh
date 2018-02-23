#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf cmake-3.10.2.tar.gz
cd cmake-3.10.2
mkdir build && cd build

PREFIX=/usr/local

# Calculates the optimal job count
JOBS=$(getThreadCount)

# bootstrap script variables
export CFLAGS='-O3 -s'
export CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'
export LDFLAGS='-Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

../bootstrap \
  --prefix=$PREFIX \
  --parallel=$JOBS

make -j $JOBS && make -j $JOBS install

# make this image a package
packageIncluding /usr/local/share/terminfo
