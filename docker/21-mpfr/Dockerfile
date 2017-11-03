# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as mpfr_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.6.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/gmp as gmp
RUN tar -cf /tmp/gmp.tar /usr/local/

# intermediate build stage
FROM busybox as mpfr_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=gmp /tmp/gmp.tar /tmp/
RUN  tar --directory / -xf /tmp/gmp.tar && \
  rm /tmp/gmp.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=mpfr_fetch /tmp/mpfr-3.1.6.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as mpfr

COPY --from=mpfr_build /tmp/install/ /usr/local/
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=gmp /tmp/gmp.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar
RUN tar --directory / -xf /tmp/gmp.tar \
        $(tar --list -f /tmp/gmp.tar | grep -E 'libgmp\.so.*') && \
    rm /tmp/gmp.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make,\
metabarj0/gmp"
