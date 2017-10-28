#!/bin/sh
tar -xf node-v8.7.0.tar.gz
cd node-v8.7.0

./configure \
  --prefix=/tmp/install \
  --dest-cpu=x64 \
  --dest-os=linux \
  --with-intl=system-icu

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

export CC=gcc
export CXX=g++
export CFLAGS='-O3 -s'
export CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'
export LDFLAGS='-Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'
make -j $JOBS && make install

strip /tmp/install/bin/node

# the shabang is not cool in lots of scripts, pointing to a wrong location for 'env'
# the chosen way to fix modify the nodejs installation itself, not an environment
# alteration. Thus, it'll be more easy to use this image as base block to build more
# complex images
cd /tmp/install

for f in $(find . -type f -exec grep -EH '^#!\/usr\/bin\/env' {} \; | sed 's/:.*//g'); do
  sed -i'' -r 's/^#!\/usr\/bin\/env/#!\/bin\/env/' $f
done
