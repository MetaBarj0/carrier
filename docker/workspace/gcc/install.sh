#!/bin/sh

cd /tmp

# move and cleanup libraries
tar -xf amd64-linux-musl.tar.xz --directory / && \
  cp /usr/local/amd64-linux-musl/lib64/* /usr/local/amd64-linux-musl/lib/ && \
  cp -r /usr/local/amd64-linux-musl/* /usr/local/ && \
  rm -rf /usr/local/amd64-linux-musl && \
  rm /tmp/amd64-linux-musl.tar.xz && \
  rm /tmp/install.sh

# fix links necessary for the dynamic loader to work
ln -sf /usr/local/lib/libc.so /usr/local/lib/ld-musl-x86_64.so.1
mkdir -p /lib
cp -P /usr/local/lib/ld-musl-x86_64.so.1 /lib/

cd /usr/local/bin

# create a bucn of handful aliases
for f in amd64-linux-musl-*; do
  ln -s $f $(echo $f | sed 's/amd64-linux-musl-//g')
done
