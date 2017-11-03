# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as go_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://storage.googleapis.com/golang/go1.4-bootstrap-20170531.tar.gz && \
    wget --no-check-certificate http://golang.org/dl/go1.9.2.src.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/

# intermediate build stage
FROM busybox as go_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=go_fetch /tmp/go1.9.2.src.tar.gz .
COPY --from=go_fetch /tmp/go1.4-bootstrap-20170531.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as go

COPY --from=go_build /usr/local/go/ /usr/local/go/
COPY --from=gcc /tmp/gcc.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar

ENV PATH /usr/local/go/bin:${PATH}

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make"
