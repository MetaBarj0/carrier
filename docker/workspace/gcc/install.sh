#!/bin/sh

cd /tmp

tar -xf amd64-linux-musl.tar.xz --directory / && \
  rm /tmp/amd64-linux-musl.tar.xz && \
  rm /tmp/install.sh

# fix links necessary for the dynamic loader to work
ln -sf /usr/local/lib/libc.so /usr/local/lib/ld-musl-x86_64.so.1
cp -P /usr/local/lib/ld-musl-x86_64.so.1 /lib/

cd /usr/local/bin

for f in amd64-linux-musl-*; do
  ln -s $f $(echo $f | sed 's/amd64-linux-musl-//g')
done
