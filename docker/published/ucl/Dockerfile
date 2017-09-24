FROM busybox as busybox
WORKDIR /tmp
RUN wget http://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make

FROM busybox as ucl-build
COPY build.sh /tmp/
COPY --from=busybox /tmp/ucl-1.03.tar.gz /tmp/
COPY --from=gcc /usr/local /usr/local/
COPY --from=make /usr/local /usr/local/
RUN /tmp/build.sh

FROM busybox
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=ucl-build /tmp/install/ /usr/local/
