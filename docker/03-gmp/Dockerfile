# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM alpine as gmp_fetch
RUN apk add --no-cache wget
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/m4 as m4
RUN tar -cf /tmp/m4.tar /usr/local/

# intermediate build stage
FROM busybox as gmp_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=m4 /tmp/m4.tar /tmp/
RUN  tar --directory / -xf /tmp/m4.tar && \
  rm /tmp/m4.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=gmp_fetch /tmp/gmp-6.1.2.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as gmp
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=gmp_build /tmp/install/ /usr/local/
RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libgcc_s\.so.*') && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libstdc\+\+\.so.*') && \
    rm -rf /tmp/gcc.tar
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/make,\
metabarj0/m4"
