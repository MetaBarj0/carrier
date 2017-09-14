#!/bin/sh

cd /tmp
mkdir -p /usr/local
tar -xf amd64-linux-musl.tar.xz --directory /usr/local/ && \
  mv /usr/local/amd64-linux-musl/* /usr/local/ && \
  ln -s /usr/local/bin/amd64-linux-musl-as /usr/local/bin/as && \
  rm -r /usr/local/amd64-linux-musl && \
  rm /tmp/amd64-linux-musl.tar.xz && \
  rm /tmp/install.sh && \
  mv /tmp/forward-command.sh /usr/local/bin/
