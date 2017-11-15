#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf openssh-7.6p1.tar.gz
cd openssh-7.6p1
mkdir build && cd build

PREFIX=/usr/local

../configure \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/lib64/,-rpath-link,/usr/local/lib64/' \
  --prefix=$PREFIX

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# # add a privilege separation user and group
# addgroup sshd
# adduser -D -H -G sshd sshd

# explicitely add this directory to prevent an install error
mkdir -p ${PREFIX}/lib

make -j $JOBS && make install

# make this image a package
packageIncluding ${PREFIX}/ssl
