#!/bin/sh
tar -xf Python-3.6.3.tar.xz
cd Python-3.6.3
mkdir build && cd build

# copy the custom setup file to enable ssl support
cp -f Setup Python-3.6.3/Modules/

../configure \
  --prefix=/tmp/install \
  --enable-shared \
  --enable-optimizations \
  --with-lto \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# remove all compiled python files that will contain wrong paths
find /tmp/install/lib/python3.6 -type f -name '*.pyc' -delete

# changing python path in shabangs
for f in $(find /tmp/install/bin -exec grep -H '#!/tmp/install' {} \; | sed 's/:.*$//g'); do
  sed -i'' 's/#!\/tmp\/install/#!\/usr\/local/' $f
done

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;

# fix prefix in pkgconfig files
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/python-3.6.pc
