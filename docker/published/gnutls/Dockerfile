FROM alpine as gnutls_fetch
WORKDIR /tmp
RUN apk add --no-cache wget && \
    wget --no-check-certificate https://ftp.gnu.org/gnu/gnutls/gnutls-3.1.5.tar.xz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make
FROM metabarj0/nettle as nettle
FROM metabarj0/gmp as gmp

FROM busybox as gnutls_build

COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/
COPY --from=nettle /usr/local/ /usr/local/
COPY --from=gmp /usr/local/ /usr/local/

WORKDIR /tmp
COPY --from=gnutls_fetch /tmp/gnutls-3.1.5.tar.xz .
COPY build.sh .
RUN ./build.sh

FROM busybox as gnutls
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=gnutls_build /tmp/install/ /usr/local/
