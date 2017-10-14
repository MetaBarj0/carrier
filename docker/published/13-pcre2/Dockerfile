# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as pcre2_fetch
WORKDIR /tmp
RUN wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-10.30.tar.bz2

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/

# intermediate build stage
FROM busybox as pcre2_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=pcre2_fetch /tmp/pcre2-10.30.tar.bz2 .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as pcre2
COPY --from=pcre2_build /tmp/install/ /usr/local/
COPY --from=gcc /lib/ /lib/
COPY --from=gcc /usr/local/lib/libc.so /usr/local/lib/
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
