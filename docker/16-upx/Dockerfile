FROM metabarj0/wget as upx_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/metabarj0/symmetrical-barnacle/raw/master/upx/master/20170925/upx-master.tar.xz

FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/ucl as ucl
RUN tar -cf /tmp/ucl.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/

FROM busybox as upx_build
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar
COPY --from=ucl /tmp/ucl.tar /tmp/
RUN  tar --directory / -xf /tmp/ucl.tar && \
  rm /tmp/ucl.tar
COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar

WORKDIR /tmp
COPY --from=upx_fetch /tmp/upx-master.tar.xz .
COPY build.sh .
RUN ./build.sh

FROM busybox as upx
COPY --from=upx_build /tmp/install/ /usr/local/
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
