FROM metabarj0/wget as openssl_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.openssl.org/source/openssl-1.0.2l.tar.gz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make
FROM metabarj0/zlib as zlib

FROM alpine as openssl_build

RUN apk add --no-cache perl

COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/
COPY --from=zlib /usr/local/ /usr/local/

WORKDIR /tmp
COPY --from=openssl_fetch /tmp/openssl-1.0.2l.tar.gz .
COPY build.sh .
RUN ./build.sh

FROM busybox as openssl
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=openssl_build /tmp/install/ /usr/local/
COPY --from=openssl_build /usr/local/ssl/ /usr/local/ssl/
