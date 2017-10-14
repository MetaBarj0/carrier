FROM busybox as ucl_fetch
WORKDIR /tmp
RUN wget http://www.oberhumer.com/opensource/ucl/download/ucl-1.03.tar.gz

FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/

FROM busybox as ucl_build
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

WORKDIR /tmp
COPY --from=ucl_fetch /tmp/ucl-1.03.tar.gz .
COPY build.sh .
RUN ./build.sh

FROM busybox as ucl
COPY --from=ucl_build /tmp/install/ /usr/local/
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
