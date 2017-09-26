FROM alpine as nettle_fetch
RUN apk add --no-cache wget
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/nettle/nettle-3.3.tar.gz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make
FROM metabarj0/m4 as m4

FROM busybox as nettle_build

COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/
COPY --from=m4 /usr/local/ /usr/local/

WORKDIR /tmp
COPY --from=nettle_fetch /tmp/nettle-3.3.tar.gz .
COPY build.sh .
RUN ./build.sh

FROM busybox as nettle
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=nettle_build /tmp/install/ /usr/local/
