#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
exit 1
fi

# extract sources and prepare for build
tar -xf v1.8.2.tar.gz
cd ninja-1.8.2

PREFIX=/usr/local

# patching the configuration script on busybox
sed -i'' 's/#!.*/#!\/usr\/local\/bin\/python3/g' configure.py

export CFLAGS='-O3 -s'
export CXXFLAGS='-O3 -s'
export LDFLAGS='-Wl,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/'

./configure.py \
  --bootstrap \
  --platform=linux

strip ninja

mkdir -p ${PREFIX}/bin

cp ninja ${PREFIX}/bin

# remove pyc file from python invocation during build time
rm -rf ${PREFIX}/lib/python3.6

# make this image a package
package
