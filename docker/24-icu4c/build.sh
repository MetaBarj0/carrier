#!/bin/sh
tar -xf icu4c-59_1-src.tar.xz
cd icu/source
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# small fix about i18n build
ln -s /usr/local/include/locale.h /usr/local/include/xlocale.h

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;
