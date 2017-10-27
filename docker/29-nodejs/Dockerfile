# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as nodejs_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://nodejs.org/dist/v8.7.0/node-v8.7.0.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/python2 as python2
RUN tar -cf /tmp/python2.tar /usr/local/
FROM metabarj0/icu4c as icu4c
RUN tar -cf /tmp/icu4c.tar /usr/local/
FROM metabarj0/pkgconfig as pkgconfig
RUN tar -cf /tmp/pkgconfig.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/

# intermediate build stage
FROM busybox as nodejs_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=python2 /tmp/python2.tar /tmp/
RUN  tar --directory / -xf /tmp/python2.tar && \
  rm /tmp/python2.tar

COPY --from=icu4c /tmp/icu4c.tar /tmp/
RUN  tar --directory / -xf /tmp/icu4c.tar && \
  rm /tmp/icu4c.tar

COPY --from=pkgconfig /tmp/pkgconfig.tar /tmp/
RUN  tar --directory / -xf /tmp/pkgconfig.tar && \
  rm /tmp/pkgconfig.tar

COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/

COPY --from=nodejs_fetch /tmp/node-v8.7.0.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as nodejs

COPY --from=nodejs_build /tmp/install/ /usr/local/
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=icu4c /tmp/icu4c.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libgcc_s\.so.*') && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libstdc\+\+\.so.*') && \
    rm -rf /tmp/gcc.tar
RUN tar --directory / -xf /tmp/icu4c.tar \
        $(tar --list -f /tmp/icu4c.tar | grep -E 'libicui18n\.so.*') && \
    tar --directory / -xf /tmp/icu4c.tar \
        $(tar --list -f /tmp/icu4c.tar | grep -E 'libicuuc\.so.*') && \
    tar --directory / -xf /tmp/icu4c.tar \
        $(tar --list -f /tmp/icu4c.tar | grep -E 'libicudata\.so.*') && \
    rm -rf /tmp/icu4c.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
