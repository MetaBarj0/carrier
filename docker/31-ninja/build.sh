#!/bin/sh
tar -xf v1.8.2.tar.gz
cd ninja-1.8.2

# patching the configuration script on busybox
sed -i'' 's/#!.*/#!\/usr\/local\/bin\/python/g' configure.py

./configure.py \
  --bootstrap \
  --platform=linux

strip ninja

mkdir -p /tmp/install/bin

cp ninja /tmp/install/bin
