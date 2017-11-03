# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM alpine as gnutls_fetch
WORKDIR /tmp
RUN apk add --no-cache wget && \
    wget --no-check-certificate https://ftp.gnu.org/gnu/gnutls/gnutls-3.1.5.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/nettle as nettle
RUN tar -cf /tmp/nettle.tar /usr/local/
FROM metabarj0/gmp as gmp
RUN tar -cf /tmp/gmp.tar /usr/local/

# intermediate build stage
FROM busybox as gnutls_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=nettle /tmp/nettle.tar /tmp/
RUN  tar --directory / -xf /tmp/nettle.tar && \
  rm /tmp/nettle.tar

COPY --from=gmp /tmp/gmp.tar /tmp/
RUN  tar --directory / -xf /tmp/gmp.tar && \
  rm /tmp/gmp.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=gnutls_fetch /tmp/gnutls-3.1.5.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as gnutls

# copy build result and dependency tar archives for extraction
COPY --from=gnutls_build /tmp/install/ /usr/local/
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=gmp /tmp/gmp.tar /tmp/
COPY --from=nettle /tmp/nettle.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libgcc_s\.so.*') && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libstdc\+\+\.so.*') && \
    rm -rf /tmp/gcc.tar
RUN tar --directory / -xf /tmp/gmp.tar \
        $(tar --list -f /tmp/gmp.tar | grep -E 'libgmp\.so.*') && \
    rm -rf /tmp/gmp.tar
RUN tar --directory / -xf /tmp/nettle.tar \
        $(tar --list -f /tmp/nettle.tar | grep -E 'libhogweed\.so.*') && \
    tar --directory / -xf /tmp/nettle.tar \
        $(tar --list -f /tmp/nettle.tar | grep -E 'libnettle\.so.*') && \
    rm -rf /tmp/nettle.tar
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/make,\
metabarj0/nettle,\
metabarj0/gmp"
