FROM alpine as gmp_fetch
RUN apk add --no-cache wget
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make
FROM metabarj0/m4 as m4

FROM busybox as gmp_build

COPY --from=gcc /usr/local/ /usr/local/
COPY --from=gcc /lib/ /lib/
COPY --from=make /usr/local/ /usr/local/
COPY --from=m4 /usr/local/ /usr/local/

WORKDIR /tmp
COPY --from=gmp_fetch /tmp/gmp-6.1.2.tar.xz .
COPY build.sh .
RUN ./build.sh

FROM busybox as gmp
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=gmp_build /tmp/install/ /usr/local/
