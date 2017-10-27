#!/bin/sh
tar -xf openssh-7.6p1.tar.gz
cd openssh-7.6p1
mkdir build && cd build

../configure \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \
  --prefix=/tmp/install

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# add a privilege speparation user and group
addgroup sshd
adduser -D -H -G sshd sshd

# explicitely add this directory to prevent an install error
mkdir -p /tmp/install/lib

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
