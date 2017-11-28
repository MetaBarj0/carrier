#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf lua-5.3.4.tar.gz
cd lua-5.3.4

PREFIX=/usr/local

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make CFLAGS='-O3 -s' LDFLAGS='-lncurses' -j $JOBS linux

# move built files manually
cd src

mkdir -p ${PREFIX}

mv *.h ${PREFIX}/include
mv lua luac ${PREFIX}/bin
mv liblua.a ${PREFIX}/lib

# copy documentations
mkdir -p ${PREFIX}/share/lua
cd ../doc
mv * ${PREFIX}/share/lua

# make this image a package
package
