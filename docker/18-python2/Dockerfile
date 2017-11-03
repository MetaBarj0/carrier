# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as python2_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/expat as expat
RUN tar -cf /tmp/expat.tar /usr/local/
FROM metabarj0/openssl as openssl
RUN tar -cf /tmp/openssl.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/

# intermediate build stage
FROM busybox as python2_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=expat /tmp/expat.tar /tmp/
RUN  tar --directory / -xf /tmp/expat.tar && \
  rm /tmp/expat.tar

COPY --from=openssl /tmp/openssl.tar /tmp/
RUN  tar --directory / -xf /tmp/openssl.tar && \
  rm /tmp/openssl.tar

COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=python2_fetch /tmp/Python-2.7.14.tar.xz .
COPY build.sh Setup.dist ./
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as python2

# lots of python scripts use env to find the interpreter but the search in a wrong path
RUN mkdir -p /usr/bin/ && ln -s /bin/env /usr/bin/env

COPY --from=python2_build /tmp/install/ /usr/local/
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=openssl /tmp/openssl.tar /tmp/
COPY --from=zlib /tmp/zlib.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar

RUN tar --directory / -xf /tmp/openssl.tar usr/local/ssl/ && \
    tar --directory / -xf /tmp/openssl.tar \
        $(tar --list -f /tmp/openssl.tar | grep -E 'libssl\.so.*') && \
    tar --directory / -xf /tmp/openssl.tar \
        $(tar --list -f /tmp/openssl.tar | grep -E 'libcrypto\.so.*') && \
    rm -rf /tmp/openssl.tar
RUN tar --directory / -xf /tmp/zlib.tar \
        $(tar --list -f /tmp/zlib.tar | grep -E 'libz\.so.*') && \
    rm -rf /tmp/zlib.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make,\
metabarj0/expat,\
metabarj0/openssl,\
metabarj0/zlib"
