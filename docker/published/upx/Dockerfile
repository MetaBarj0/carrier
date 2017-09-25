FROM metabarj0/ucl as ucl
FROM metabarj0/gcc as gcc
FROM metabarj0/make as make
FROM metabarj0/zlib as zlib

FROM busybox as upx_build
COPY --from=ucl /usr/local/ /usr/local/
COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/
COPY --from=zlib /usr/local/ /usr/local/

WORKDIR /tmp

RUN wget https://github.com/metabarj0/symmetrical-barnacle/raw/master/upx/master/20170925/upx-master.tar.xz
COPY build.sh .
RUN ./build.sh

FROM busybox
MAINTAINER metabarj0 <troctsch.cpp@gmail.com>
COPY --from=upx_build /tmp/install/upx /usr/local/bin/
