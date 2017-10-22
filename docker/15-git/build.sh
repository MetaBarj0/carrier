#!/bin/sh
tar -xf v2.15.0-rc1.tar.gz
cd git-2.15.0-rc1

make configure

./configure \
  --prefix=/tmp/install \
  --without-tcltk \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS \
  NO_PERL=YesPlease \
  NO_GETTEXT=YesPlease \
  NO_SVN_TESTS=YesPlease \
  NO_TCLTK=YesPlease \
  NO_INSTALL_HARDLINKS=YesPlease && make install
