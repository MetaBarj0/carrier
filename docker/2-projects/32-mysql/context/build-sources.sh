#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf mysql-5.6.38.tar.gz

# deploy patches
tar --directory mysql-5.6.38 -xf patch.tar

cd mysql-5.6.38
mkdir build && cd build

PREFIX=/usr/local/mysql

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS_RELEASE='-O3 -s -DNDEBUG' \
  -DCMAKE_CXX_COMPILER=/usr/local/bin/g++ \
  -DCMAKE_CXX_FLAGS_RELEASE='-O3 -s -DNDEBUG' \
  -DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/lib64/,-rpath-link,/usr/local/lib64/,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/ \
  -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/lib64/,-rpath-link,/usr/local/lib64/,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/ \
  -DWITH_PIC=ON \
  -DWITH_SSL=system \
  -DWITH_ZLIB=system \
  ..

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

make -j $JOBS && make install

# remove unnecessary stuff
cd $PREFIX
rm -rf data mysql-test sql-bench scripts

# packaging
packageIncluding \
  /usr/local/share/terminfo \
  /usr/local/ssl \
  ${PREFIX}/configuration.tar \
  ${PREFIX}/data.tar.xz \
  ${PREFIX}/mysql_server_reset.sh \
  ${PREFIX}/mysql_server_start.sh
  
