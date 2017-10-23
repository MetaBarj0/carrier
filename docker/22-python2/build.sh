#!/bin/sh
tar -xf Python-2.7.14.tar.xz

# copy the custom setup file to enable ssl support
cp -f Setup.dist Python-2.7.14/Modules/

cd Python-2.7.14
mkdir build && cd build

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
find /tmp/install/lib/python2.7 -type f -name '*.pyc' -delete
find /tmp/install/lib/python2.7 -type f -name '*.pyo' -delete

# changing python path in shabangs
for f in $(find /tmp/install/bin -exec grep -H '#!/tmp/install' {} \; | sed 's/:.*$//g'); do
  sed -i'' 's/#!\/tmp\/install/#!\/usr\/local/' $f
done

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;

# fix prefix in pkgconfig files
sed -i'' -r 's/^prefix=.*/prefix=\/usr\/local/g' /tmp/install/lib/pkgconfig/python-2.7.pc
