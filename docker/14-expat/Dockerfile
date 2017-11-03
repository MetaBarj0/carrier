# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as expat_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/MetaBarj0/symmetrical-barnacle/raw/master/expat/2.2.4/expat-2.2.4.tar.bz2

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/

# intermediate build stage
FROM busybox as expat_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=expat_fetch /tmp/expat-2.2.4.tar.bz2 .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as expat

COPY --from=expat_build /tmp/install/ /usr/local/
COPY --from=gcc /tmp/gcc.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make"
