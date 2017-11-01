#!/bin/sh
tar -xf bash-4.4.12.tar.gz
cd bash-4.4.12
mkdir build && cd build

../configure \
  --prefix=/usr/local \
  --enable-alias \
  --enable-arith-for-command \
  --enable-array-variables \
  --enable-bang-history \
  --enable-brace-expansion \
  --enable-casemod-attributes \
  --enable-casemod-expansions \
  --enable-command-timing \
  --enable-cond-command \
  --enable-cond-regexp \
  --enable-coprocesses \
  --enable-debugger \
  --enable-direxpand-default \
  --enable-directory-stack \
  --enable-dparen-arithmetic \
  --enable-extended-glob \
  --enable-extended-glob-default \
  --enable-function-import \
  --enable-glob-asciiranges-default \
  --enable-help-builtin \
  --enable-history \
  --enable-job-control \
  --enable-multibyte \
  --enable-net-redirections \
  --enable-process-substitution \
  --enable-progcomp \
  --enable-prompt-string-decoding \
  --enable-readline \
  --enable-restricted \
  --enable-select \
  --enable-xpg-echo-default \
  --without-bash-malloc \
  --with-curses \
  --disable-nls \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/' \

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

add-shell '/usr/local/bin/bash'
