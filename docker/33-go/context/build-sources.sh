#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# building the bootstrap
tar -xf go1.4-bootstrap-20170531.tar.gz
cd go/src

# use sh instead of bash
for f in $(find . -type f -exec grep -EH '#!\s*\/usr\/bin\/env\s*bash' {} \; | sed 's/:.*//'); do
  sed -i'' -r 's/#!\s*\/usr\/bin\/env\s*bash/#!\/bin\/sh/g' $f
done

# this directory is necessary
mkdir -p /var/tmp

GOARCH='amd64' \
  CFLAGS='-O3 -s' \
  LDFLAGS='-Wl,-rpath,/usr/local/lib/,-rpath-link,/usr/local/lib/,-rpath,/usr/local/amd64-linux-musl/lib64/,-rpath-link,/usr/local/amd64-linux-musl/lib64/' \
  CGO_ENABLED=0 \
  ./make.bash --no-clean

cd /tmp/go

# manual installation needed
mkdir -p /tmp/go-bootstrap
mv src pkg bin /tmp/go-bootstrap

cd /tmp/go-bootstrap

# bootstrap built, build last version using it
cd /tmp
rm -rf go

tar -xf go1.9.2.src.tar.gz
cd go/src

# use sh instead of bash
for f in $(find . -type f -exec grep -EH '#!\s*\/usr\/bin\/env\s*bash' {} \; | sed 's/:.*//'); do
  sed -i'' -r 's/#!\s*\/usr\/bin\/env\s*bash/#!\/bin\/sh/g' $f
done

PREFIX=/usr/local/go

GOROOT_FINAL=$PREFIX \
  GOARCH='amd64' \
  GOOS='linux' \
  GOROOT_BOOTSTRAP=/tmp/go-bootstrap \
  ./make.bash

# create installation directory hierarchy and move built files
mkdir -p $PREFIX
cd /tmp/go
mv bin/ pkg/ src/ doc/ $PREFIX
cd $PREFIX

# stripping binaries
for f in bin/*; do
  strip $f
done
for f in pkg/tool/*/*; do
  strip $f
done

# removing unnecessary files
find src/ -type f -name '*_test.go' >> /tmp/unneeded_files
find src/ -type f -name '*.bash'  >> /tmp/unneeded_files
find src/ -type d -name 'testdata' >> /tmp/unneeded_files

for x in $(cat /tmp/unneeded_files); do
  rm -rf $x
done

rm -rf pkg/bootstrap

# make this image a package
package
