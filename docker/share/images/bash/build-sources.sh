#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf bash-4.4.12.tar.gz
cd bash-4.4.12
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
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
JOBS=$(getThreadCount)

make -j $JOBS && make install

add-shell '/usr/local/bin/bash'

# make this image a package
packageIncluding /usr/local/share/terminfo
