# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as openssl_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.openssl.org/source/openssl-1.0.2m.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/

# intermediate build stage
FROM metabarj0/perl as openssl_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar
COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=openssl_fetch /tmp/openssl-1.0.2m.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as openssl

COPY --from=openssl_build /tmp/install/ /usr/local/
COPY --from=openssl_build /usr/local/ssl/ /usr/local/ssl/
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=zlib /tmp/zlib.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar
RUN tar --directory / -xf /tmp/zlib.tar \
        $(tar --list -f /tmp/zlib.tar | grep -E 'libz\.so.*') && \
    rm -rf /tmp/zlib.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make,\
metabarj0/zlib"
