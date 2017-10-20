# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM alpine as nettle_fetch
RUN apk add --no-cache wget
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/nettle/nettle-2.5.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/m4 as m4
RUN tar -cf /tmp/m4.tar /usr/local/
FROM metabarj0/gmp as gmp
RUN tar -cf /tmp/gmp.tar /usr/local/

# intermediate build stage
FROM busybox as nettle_build

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

COPY --from=gmp /tmp/gmp.tar /tmp/
RUN  tar --directory / -xf /tmp/gmp.tar && \
  rm /tmp/gmp.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=nettle_fetch /tmp/nettle-2.5.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as nettle
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
COPY --from=nettle_build /tmp/install/ /usr/local
