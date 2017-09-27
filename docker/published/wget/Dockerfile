FROM alpine as wget_fetch
RUN apk add --no-cache wget
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/wget/wget-1.19.tar.xz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make
FROM metabarj0/gnutls as gnutls
FROM metabarj0/nettle as nettle
FROM metabarj0/gmp as gmp

FROM busybox as wget_build

COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/
COPY --from=gnutls /usr/local/ /usr/local/
COPY --from=nettle /usr/local/ /usr/local/
COPY --from=gmp /usr/local/ /usr/local/

WORKDIR /tmp
COPY --from=wget_fetch /tmp/wget-1.19.tar.xz .
COPY build.sh .
RUN ./build.sh

FROM busybox as wget
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=wget_build /tmp/install/ /usr/local/
