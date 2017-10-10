FROM metabarj0/wget as libssh_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://git.libssh.org/projects/libssh.git/snapshot/master.tar.gz

FROM metabarj0/gcc as gcc
FROM metabarj0/make as make
FROM metabarj0/cmake as cmake
FROM metabarj0/zlib as zlib
FROM metabarj0/openssl as openssl

FROM busybox as libssh_build
COPY --from=gcc /usr/local/ /usr/local/
COPY --from=make /usr/local/ /usr/local/
COPY --from=cmake /usr/local/ /usr/local/
COPY --from=zlib /usr/local/ /usr/local/
COPY --from=openssl /usr/local/ /usr/local/

WORKDIR /tmp
COPY --from=libssh_fetch /tmp/master.tar.gz .
COPY build.sh .
# RUN ./build.sh
