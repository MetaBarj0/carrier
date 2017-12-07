#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf perl-5.26.1.tar.gz
cd perl-5.26.1

PREFIX=/usr/local/perl

./Configure -des \
  -Dcc='gcc' \
  -Dcccdlflags='-fPIC' \
  -Dccdlflags='-rdynamic' \
  -Dprefix=$PREFIX \
  -Dprivlib=$PREFIX'/share/perl5/core_perl' \
  -Darchlib=$PREFIX'/lib/perl5/core_perl' \
  -Dvendorprefix=$PREFIX \
  -Dvendorlib=$PREFIX'/share/perl5/core_perl' \
  -Dvendorarch=$PREFIX'/lib/perl5/core_perl' \
  -Dsiteprefix=$PREFIX \
  -Dsitelib=$PREFIX'/share/perl5/core_perl' \
  -Dsitearch=$PREFIX'/lib/perl5/core_perl' \
  -Dlocincpth=' ' \
  -Doptimize='-O3 -s' \
  -Duselargefiles \
  -Dusethreads \
  -Duseshrplib \
  -Dd_semctl_semun \
  -Dcf_by='metabarj0 <troctsch.cpp@gmail.com>, inspired by Alpine Linux perl package' \
  -Ud_csh \
  -Dusenm

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make depend && make -j $JOBS && make install

# make this image a package
package
