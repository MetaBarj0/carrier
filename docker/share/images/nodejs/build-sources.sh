#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf node-v8.11.1.tar.gz
cd node-v8.11.1

PREFIX=/usr/local

./configure \
  --prefix=$PREFIX \
  --dest-cpu=x64 \
  --dest-os=linux \
  --with-intl=system-icu

# Calculates the optimal job count
JOBS=$(getThreadCount)

export CC=gcc
export CXX=g++
export CFLAGS='-O3 -s'
export CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'
export LDFLAGS='-Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'
make -j $JOBS && make install

strip ${PREFIX}/bin/node

# the shabang is not cool in lots of scripts, pointing to a wrong location for
# 'env' the chosen way to fix modify the nodejs installation itself, not an
# environment alteration. Thus, it'll be more easy to use this image as base
# block to build more complex images
cd $PREFIX

for f in $(find . -type f -exec grep -EH '^#!\/usr\/bin\/env' {} \; \
	   | sed 's/:.*//g'); do
  sed -i'' -r 's/^#!\/usr\/bin\/env/#!\/bin\/env/' $f
done

# remove pyc file from python invocation during build time
rm -rf ${PREFIX}/lib/python2.7

# make this image a package
package
