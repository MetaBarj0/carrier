# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as mysql_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.38.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/cmake as cmake
RUN tar -cf /tmp/cmake.tar /usr/local/
FROM metabarj0/ncurses as ncurses
RUN tar -cf /tmp/ncurses.tar /usr/local/
FROM metabarj0/zlib as zlib
RUN tar -cf /tmp/zlib.tar /usr/local/
FROM metabarj0/openssl as openssl
RUN tar -cf /tmp/openssl.tar /usr/local/

# intermediate build stage
FROM metabarj0/perl as mysql_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar

COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar

COPY --from=cmake /tmp/cmake.tar /tmp/
RUN  tar --directory / -xf /tmp/cmake.tar && \
  rm /tmp/cmake.tar

COPY --from=ncurses /tmp/ncurses.tar /tmp/
RUN  tar --directory / -xf /tmp/ncurses.tar && \
  rm /tmp/ncurses.tar

COPY --from=zlib /tmp/zlib.tar /tmp/
RUN  tar --directory / -xf /tmp/zlib.tar && \
  rm /tmp/zlib.tar

COPY --from=openssl /tmp/openssl.tar /tmp/
RUN  tar --directory / -xf /tmp/openssl.tar && \
  rm /tmp/openssl.tar

# mandatory for ncurses
ENV TERMINFO /usr/local/share/terminfo

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=mysql_fetch /tmp/mysql-5.6.38.tar.gz .
COPY build.sh patch.tar ./
RUN ./build.sh && \
    rm -rf /usr/local/mysql/data

# final stage, copy the result in a busybox image
FROM busybox as mysql

COPY --from=mysql_build /usr/local/mysql/ /usr/local/mysql/

ENV PATH /usr/local/mysql/bin:${PATH}

COPY configuration.tar data.tar.bz2 mysql_server_reset.sh mysql_server_start.sh /usr/local/mysql/

# grab third party libraries
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=openssl /tmp/openssl.tar /tmp/
COPY --from=zlib /tmp/zlib.tar /tmp/
COPY --from=ncurses /tmp/ncurses.tar /tmp/

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
RUN tar --directory / -xf /tmp/openssl.tar \
        $(tar --list -f /tmp/openssl.tar | grep -E 'libcrypto\.so.*') && \
    tar --directory / -xf /tmp/openssl.tar \
        $(tar --list -f /tmp/openssl.tar | grep -E 'libssl\.so.*') && \
    rm -rf /tmp/openssl.tar
RUN tar --directory / -xf /tmp/zlib.tar \
        $(tar --list -f /tmp/zlib.tar | grep -E 'libz\.so.*') && \
    rm -rf /tmp/zlib.tar
RUN tar --directory / -xf /tmp/ncurses.tar \
        $(tar --list -f /tmp/ncurses.tar | grep -E 'libncurses\.so.*') && \
    rm -rf /tmp/ncurses.tar

VOLUME [ "/usr/local/mysql/data/" ]
VOLUME [ "/usr/local/mysql/etc/" ]

EXPOSE 3306

ENTRYPOINT [ "/usr/local/mysql/mysql_server_start.sh" ]

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
