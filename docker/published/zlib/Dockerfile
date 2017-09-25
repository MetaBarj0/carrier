FROM metabarj0/gcc as gcc
FROM metabarj0/make as make

FROM busybox as zlib_build

WORKDIR /tmp

RUN wget https://zlib.net/zlib-1.2.11.tar.xz

COPY build.sh .

COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/

RUN ./build.sh

FROM busybox
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=zlib_build /tmp/install/ /usr/local
