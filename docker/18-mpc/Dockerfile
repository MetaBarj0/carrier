# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as mpc_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz

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

# intermediate build stage
FROM busybox as mpc_build

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

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=mpc_fetch /tmp/mpc-1.0.3.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as mpc
COPY --from=mpc_build /tmp/install/ /usr/local/
COPY --from=gcc /lib/ /lib/
COPY --from=gcc /usr/local/lib/libc.so /usr/local/lib/
COPY --from=gmp /tmp/gmp.tar /tmp/
RUN  tar --directory / -xf /tmp/gmp.tar usr/local/lib/ && \
  rm /tmp/gmp.tar
COPY --from=mpfr /tmp/mpfr.tar /tmp/
RUN  tar --directory / -xf /tmp/mpfr.tar usr/local/lib/ && \
  rm /tmp/mpfr.tar
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
