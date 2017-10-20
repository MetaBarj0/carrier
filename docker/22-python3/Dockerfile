# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as python3_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/expat as expat
RUN tar -cf /tmp/expat.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/

# intermediate build stage
FROM busybox as python3_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=expat /tmp/expat.tar /tmp/
RUN  tar --directory / -xf /tmp/expat.tar && \
  rm /tmp/expat.tar

COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=python3_fetch /tmp/Python-3.6.3.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as python3
COPY --from=python3_build /tmp/install/ /usr/local/
COPY --from=gcc /lib/ /lib/
COPY --from=gcc /usr/local/lib/libc.so /usr/local/lib/
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
