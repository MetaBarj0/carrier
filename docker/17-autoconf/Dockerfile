# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as autoconf_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/m4 as m4
RUN tar -cf /tmp/m4.tar /usr/local/
FROM metabarj0/perl as perl
RUN tar -cf /tmp/perl.tar /usr/local/perl/

# intermediate build stage
FROM busybox as autoconf_build

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

COPY --from=perl /tmp/perl.tar /tmp/
RUN  tar --directory / -xf /tmp/perl.tar && \
  rm /tmp/perl.tar

ENV PATH /usr/local/perl/bin:${PATH}

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=autoconf_fetch /tmp/autoconf-2.69.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as autoconf

COPY --from=autoconf_build /tmp/install/ /usr/local
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=perl /tmp/perl.tar /tmp/
COPY --from=m4 /tmp/m4.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar

RUN tar --directory / -xf /tmp/perl.tar && \
    rm -rf /tmp/perl.tar

RUN tar --directory / -xf /tmp/m4.tar && \
    rm -rf /tmp/m4.tar

ENV PATH /usr/local/perl/bin:${PATH}

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make,\
metabarj0/m4,\
metabarj0/perl"
