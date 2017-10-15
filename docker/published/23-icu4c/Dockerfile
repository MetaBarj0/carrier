# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as icu4c_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/MetaBarj0/symmetrical-barnacle/raw/master/icu4c/59-1/icu4c-59_1-src.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
# FROM metabarj0/python2 as python2
# RUN tar -cf /tmp/python2.tar /usr/local/

# intermediate build stage
FROM busybox as icu4c_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

# COPY --from=python2 /tmp/python2.tar /tmp/
# RUN  tar --directory / -xf /tmp/python2.tar && \
#   rm /tmp/python2.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=icu4c_fetch /tmp/icu4c-59_1-src.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as icu4c
COPY --from=icu4c_build /tmp/install/ /usr/local/

# grab libraries from gcc.
COPY --from=gcc /tmp/gcc.tar /tmp/

# because of poor tar implementation in busybox, especially about
# wildcard support, need to do this awful hack
RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep libgcc_s.so*) && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep libstdc++.so*) && \
    rm -rf /tmp/gcc.tar
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
