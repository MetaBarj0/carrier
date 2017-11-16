#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf Python-2.7.14.tar.xz

# copy the custom setup file to enable ssl support
cp -f Setup.dist Python-2.7.14/Modules/

cd Python-2.7.14
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-shared \
  --enable-optimizations \
  --with-lto \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/lib64/,-rpath-link,/usr/local/lib64/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# remove all compiled python files that will contain wrong paths
find ${PREFIX}/lib/python2.7 -type f -name '*.pyc' -delete
find ${PREFIX}/lib/python2.7 -type f -name '*.pyo' -delete

# make this image a package
packageIncluding metabarj0/openssl
