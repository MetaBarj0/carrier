#!/bin/sh
tar -xf openssl-1.0.2m.tar.gz
cd openssl-1.0.2m

./config \
  --prefix=/tmp/install \
  --openssldir=/usr/local/ssl \
  shared zlib \
  -O3 -s \
  -Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make test && make install

# remove an unneeded perl script
rm /tmp/install/bin/c_rehash

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;

# fix prefix in pkgconfig files
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/libssl.pc
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/libcrypto.pc
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/openssl.pc
