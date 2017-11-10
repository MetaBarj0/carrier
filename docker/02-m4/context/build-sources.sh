#!/bin/sh

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-threads=posix \
  --enable-c++ \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# get the diff between now and before the project was built, only in the prefix
# directory. Produce a list of added files after the build and installation
docker diff $(hostname) | grep 'A '$PREFIX | sed 's/A\s//' > /image.dist

# adding dependencies (libs and so on...)
cat << EOI >> /image.dist
/lib
/usr/local/lib/libc.so
EOI

# intermediate clean
docker image prune -f

# commit changes
docker commit $(hostname) $REPOSITORY
