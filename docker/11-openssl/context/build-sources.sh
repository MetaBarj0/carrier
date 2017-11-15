#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf openssl-1.0.2m.tar.gz
cd openssl-1.0.2m

PREFIX=/usr/local

./config \
  --prefix=$PREFIX \
  --openssldir=${PREFIX}/ssl \
  shared zlib \
  -O3 -s \
  -Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make test && make install

# remove an unneeded perl script
rm ${PREFIX}/bin/c_rehash

# make this image a package
package
