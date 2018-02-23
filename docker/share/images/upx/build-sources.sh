#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf upx-master.tar.xz
cd upx-master

# change the script interpreter to /bin/sh
sed -i'' 's/#!.*/#!\/bin\/sh/g' src/stub/scripts/check_whitespace.sh

# Calculates the optimal job count
JOBS=$(getThreadCount)

CXXFLAGS='-O3 -s -Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/' \
  make -j $JOBS all CHECK_WHITESPACE=/bin/true

PREFIX=/usr/local

mkdir -p ${PREFIX}/bin

mv src/upx.out ${PREFIX}/bin/upx

# make this image a package
package
