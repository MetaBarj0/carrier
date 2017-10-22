# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as git_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/git/git/archive/v2.15.0-rc1.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/openssh as openssh
RUN tar -cf /tmp/openssh.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/
FROM metabarj0/curl as curl
RUN tar -cf /tmp/curl.tar /usr/local/
FROM metabarj0/openssl as openssl
RUN tar -cf /tmp/openssl.tar /usr/local/
FROM metabarj0/expat as expat
RUN tar -cf /tmp/expat.tar /usr/local/
FROM metabarj0/pcre2 as pcre2
RUN tar -cf /tmp/pcre2.tar /usr/local/
FROM metabarj0/python2 as python2
RUN tar -cf /tmp/python2.tar /usr/local/

# intermediate build stage
FROM alpine as git_build

# TODO : build these project too
RUN apk add --no-cache perl autoconf gettext

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar
COPY --from=openssh /tmp/openssh.tar /tmp/
RUN  tar --directory / -xf /tmp/openssh.tar && \
  rm /tmp/openssh.tar
COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar
COPY --from=curl /tmp/curl.tar /tmp/
RUN  tar --directory / -xf /tmp/curl.tar && \
  rm /tmp/curl.tar
COPY --from=openssl /tmp/openssl.tar /tmp/
RUN  tar --directory / -xf /tmp/openssl.tar && \
  rm /tmp/openssl.tar
COPY --from=expat /tmp/expat.tar /tmp/
RUN  tar --directory / -xf /tmp/expat.tar && \
  rm /tmp/expat.tar
COPY --from=pcre2 /tmp/pcre2.tar /tmp/
RUN  tar --directory / -xf /tmp/pcre2.tar && \
  rm /tmp/pcre2.tar
COPY --from=python2 /tmp/python2.tar /tmp/
RUN  tar --directory / -xf /tmp/python2.tar && \
  rm /tmp/python2.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=git_fetch /tmp/v2.15.0-rc1.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as git

COPY --from=git_build /tmp/install/ /usr/local/
COPY pre-execute.sh /usr/local/bin/
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=openssl /tmp/openssl.tar /tmp/
COPY --from=curl /tmp/curl.tar /tmp/
COPY --from=expat /tmp/expat.tar /tmp/
COPY --from=zlib /tmp/zlib.tar /tmp/
COPY --from=openssh /tmp/openssh.tar /tmp/
COPY --from=python2 /tmp/python2.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar
RUN tar --directory / -xf /tmp/openssl.tar \
        $(tar --list -f /tmp/openssl.tar | grep -E 'libssl\.so.*') && \
    tar --directory / -xf /tmp/openssl.tar \
        $(tar --list -f /tmp/openssl.tar | grep -E 'libcrypto\.so.*') && \
    rm -rf /tmp/openssl.tar
RUN tar --directory / -xf /tmp/curl.tar \
        $(tar --list -f /tmp/curl.tar | grep -E 'libcurl\.so.*') && \
    rm -rf /tmp/curl.tar
RUN tar --directory / -xf /tmp/zlib.tar \
        $(tar --list -f /tmp/zlib.tar | grep -E 'libz\.so.*') && \
    rm -rf /tmp/zlib.tar
RUN tar --directory / -xf /tmp/expat.tar \
        $(tar --list -f /tmp/expat.tar | grep -E 'libexpat\.so.*') && \
    rm -rf /tmp/expat.tar
RUN tar --directory / -xf /tmp/python2.tar && \
  rm -rf /tmp/python2.tar
RUN tar --directory / -xf /tmp/openssh.tar && \
  rm -rf /tmp/openssh.tar

# check and forward commands
ENTRYPOINT [ "pre-execute.sh" ]

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
