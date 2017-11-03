# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as boost_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.bz2

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/icu4c as icu4c
RUN tar -cf /tmp/icu4c.tar /usr/local/
FROM metabarj0/python2 as python2
RUN tar -cf /tmp/python2.tar /usr/local/

# intermediate build stage
FROM busybox as boost_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=icu4c /tmp/icu4c.tar /tmp/
RUN  tar --directory / -xf /tmp/icu4c.tar && \
  rm /tmp/icu4c.tar

COPY --from=python2 /tmp/python2.tar /tmp/
RUN  tar --directory / -xf /tmp/python2.tar && \
  rm /tmp/python2.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=boost_fetch /tmp/boost_1_65_1.tar.bz2 .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as boost
COPY --from=boost_build /tmp/install/ /usr/local/

# grab libraries from gcc.
COPY --from=gcc /tmp/gcc.tar /tmp/

# because of poor tar implementation in busybox, especially about
# wildcard support, need to do this awful hack
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
metabarj0/wget,\
metabarj0/make,\
metabarj0/icu4c,\
metabarj0/python2"
