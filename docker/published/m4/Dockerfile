FROM alpine as m4_fetch
RUN apk add --no-cache wget
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make

FROM busybox as m4_build

COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/

WORKDIR /tmp
COPY --from=m4_fetch /tmp/m4-1.4.18.tar.xz .
COPY build.sh .
RUN ./build.sh

FROM busybox as m4
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=m4_build /tmp/install/ /usr/local
