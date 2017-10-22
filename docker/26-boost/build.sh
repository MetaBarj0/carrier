#!/bin/sh
tar -xf boost_1_65_1.tar.bz2
cd boost_1_65_1

./bootstrap.sh \
  --prefix=/tmp/install

./b2 install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
