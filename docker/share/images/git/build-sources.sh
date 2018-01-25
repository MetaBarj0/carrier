#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf v2.16.1.tar.gz
cd git-2.16.1

make configure

PREFIX=/usr/local

./configure \
  --prefix=$PREFIX \
  --with-perl=/usr/local/perl/bin/perl \
  --without-tcltk \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib,-rpath-link,/usr/local/lib/'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS \
  NO_PERL=YesPlease \
  NO_SVN_TESTS=YesPlease \
  NO_TCLTK=YesPlease \
  NO_INSTALL_HARDLINKS=YesPlease && make install

# make this image a package, packaging the entrypoint as well
packageIncluding \
  /usr/local/bin/entrypoint.sh \
  metabarj0/python2 \
  metabarj0/openssh \
  metabarj0/diffutils
