#!/bin/sh
tar -xf v1.8.2.tar.gz
cd ninja-1.8.2

# patching the configuration script on busybox
sed -i'' 's/#!.*/#!\/usr\/local\/bin\/python/g' configure.py

export CFLAGS='-O3 -s'
export CXXFLAGS='-O3 -s'
export LDFLAGS='-Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'

./configure.py \
  --bootstrap \
  --platform=linux

strip ninja

mkdir -p /tmp/install/bin

cp ninja /tmp/install/bin
