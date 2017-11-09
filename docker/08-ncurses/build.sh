#!/bin/sh
tar -xf ncurses-6.0.tar.gz
cd ncurses-6.0
mkdir build && cd build

../configure \
  --prefix=/tmp/install \
  --without-ada \
  --disable-termcap \
  --disable-rpath-hack \
  --with-shared \
  --without-cxx-binding \
  --with-pthread \
  --enable-weak-symbols \
  --with-terminfo-dirs="/etc/terminfo:/usr/local/share/terminfo" \
  --enable-pc-files \
  --enable-widec \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# relocate installed libraries
find /tmp/install/lib -type f -name '*.la' -exec \
  sed -i'' 's/\/tmp\/install\//\/usr\/local\//g' {} \;

# create links on produced libraries
cd /tmp/install/lib
for f in libncurses*; do
  ln -s $f $(echo $f | sed 's/libncursesw/libncurses/')
done
