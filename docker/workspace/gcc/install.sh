#!/bin/sh

cd /tmp

mkdir -p /usr/local

tar -xf amd64-linux-musl.tar.xz --directory /usr/local/ && \
  mv /usr/local/amd64-linux-musl/* /usr/local/ && \
  rm -r /usr/local/amd64-linux-musl && \
  rm /tmp/amd64-linux-musl.tar.xz && \
  rm /tmp/install.sh && \
  mv /tmp/forward-command.sh /usr/local/bin/

for f in amd64-linux-musl-* do;
  ln -s $f $(echo $f | sed 's/amd64-linux-musl-//g')
done
