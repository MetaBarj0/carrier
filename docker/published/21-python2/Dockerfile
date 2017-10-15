# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as python2_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/expat as expat
RUN tar -cf /tmp/expat.tar /usr/local/
FROM metabarj0/openssl as openssl
RUN tar -cf /tmp/openssl.tar /usr/local/

# intermediate build stage
FROM busybox as python2_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

copy --from=expat /tmp/expat.tar /tmp/
run  tar --directory / -xf /tmp/expat.tar && \
  rm /tmp/expat.tar

copy --from=openssl /tmp/openssl.tar /tmp/
run  tar --directory / -xf /tmp/openssl.tar && \
  rm /tmp/openssl.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=python2_fetch /tmp/Python-2.7.14.tar.xz .
COPY build.sh Setup.dist ./
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as python2
COPY --from=python2_build /tmp/install/ /usr/local/
COPY --from=gcc /lib/ /lib/
COPY --from=gcc /usr/local/lib/libc.so /usr/local/lib/

COPY --from=openssl /tmp/openssl.tar /tmp/
RUN tar --directory / -xf /tmp/openssl.tar usr/local/lib/ usr/local/ssl/ && \
    rm -rf /tmp/openssl.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
