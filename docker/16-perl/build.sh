#!/bin/sh
tar -xf perl-5.26.1.tar.gz
cd perl-5.26.1

./Configure -des \
  -Dcc='gcc' \
  -Dcccdlflags='-fPIC' \
  -Dccdlflags='-rdynamic' \
  -Dprefix='/usr/local/perl' \
  -Dprivlib='/usr/local/perl/share/perl5/core_perl' \
  -Darchlib='/usr/local/perl/lib/perl5/core_perl' \
  -Dvendorprefix='/usr/local/perl' \
  -Dvendorlib='/usr/local/perl/share/perl5/core_perl' \
  -Dvendorarch='/usr/local/perl/lib/perl5/core_perl' \
  -Dsiteprefix='/usr/local/perl' \
  -Dsitelib='/usr/local/perl/share/perl5/core_perl' \
  -Dsitearch='/usr/local/perl/lib/perl5/core_perl' \
  -Dlocincpth=' ' \
  -Doptimize='-O3 -s' \
  -Duselargefiles \
  -Dusethreads \
  -Duseshrplib \
  -Dd_semctl_semun \
  -Dcf_by='metabarj0 <troctsch@gmail.com>, inspired by Alpine Linux perl package' \
  -Ud_csh \
  -Dusenm

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make depend && make -j $JOBS && make install
