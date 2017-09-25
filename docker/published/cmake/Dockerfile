FROM metabarj0/gcc as gcc
FROM metabarj0/make as make

FROM busybox as cmake_build
COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/

WORKDIR /tmp
RUN wget https://cmake.org/files/v3.9/cmake-3.9.3.tar.gz
COPY build.sh .
RUN ./build.sh

FROM busybox
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=cmake_build /tmp/install/ /usr/local/
