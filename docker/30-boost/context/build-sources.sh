#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf boost_1_65_1.tar.bz2
cd boost_1_65_1

PREFIX=/usr/local

# fixing build issue when using CPU_ZERO macro
sed -i'' '75i\void *memset (void *, int, size_t);' ${PREFIX}/include/sched.h

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

./bootstrap.sh \
  --prefix=$PREFIX

./b2 -j$JOBS install

# remove pyc file from python invocation during build time
rm -rf ${PREFIX}/lib/python2.7

# make this image a package
packageIncluding ${PREFIX}/include/sched.h
