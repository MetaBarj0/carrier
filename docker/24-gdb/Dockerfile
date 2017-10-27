# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as gdb_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/gdb/gdb-8.0.1.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/gmp as gmp
RUN tar -cf /tmp/gmp.tar /usr/local/
FROM metabarj0/mpfr as mpfr
RUN tar -cf /tmp/mpfr.tar /usr/local/
FROM metabarj0/mpc as mpc
RUN tar -cf /tmp/mpc.tar /usr/local/
FROM metabarj0/isl as isl
RUN tar -cf /tmp/isl.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/

# intermediate build stage
FROM busybox as gdb_build

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

COPY --from=mpfr /tmp/mpfr.tar /tmp/
RUN  tar --directory / -xf /tmp/mpfr.tar && \
  rm /tmp/mpfr.tar

COPY --from=mpc /tmp/mpc.tar /tmp/
RUN  tar --directory / -xf /tmp/mpc.tar && \
  rm /tmp/mpc.tar

COPY --from=isl /tmp/isl.tar /tmp/
RUN  tar --directory / -xf /tmp/isl.tar && \
  rm /tmp/isl.tar

COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=gdb_fetch /tmp/gdb-8.0.1.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as gdb

COPY --from=gdb_build /tmp/install/ /usr/local/
COPY --from=gcc /tmp/gcc.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
