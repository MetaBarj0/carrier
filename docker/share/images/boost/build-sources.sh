#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf boost_1_66_0.tar.bz2
cd boost_1_66_0

PREFIX=/usr/local

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

./bootstrap.sh \
  --prefix=$PREFIX

./b2 -j$JOBS install

# remove pyc file from python invocation during build time
rm -rf ${PREFIX}/lib/python2.7

# TODO verify if this file is needed since musl-1.18 release
# make this image a package
packageIncluding ${PREFIX}/include/sched.h
