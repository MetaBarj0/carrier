# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as cmake_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://cmake.org/files/v3.10/cmake-3.10.0-rc1.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/ncurses as ncurses
RUN tar -cf /tmp/ncurses.tar /usr/local/

# intermediate build stage
FROM busybox as cmake_build

# copy and extract tarballs
COPY --from=gcc /tmp/gcc.tar /tmp/
RUN  tar --directory / -xf /tmp/gcc.tar && \
  rm /tmp/gcc.tar
COPY --from=make /tmp/make.tar /tmp/
RUN  tar --directory / -xf /tmp/make.tar && \
  rm /tmp/make.tar
COPY --from=ncurses /tmp/ncurses.tar /tmp/
RUN  tar --directory / -xf /tmp/ncurses.tar && \
  rm /tmp/ncurses.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=cmake_fetch /tmp/cmake-3.10.0-rc1.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as cmake

COPY --from=cmake_build /tmp/install/ /usr/local/
COPY --from=gcc /tmp/gcc.tar /tmp/
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

RUN tar --directory / -xf /tmp/ncurses.tar \
        usr/local/share/terminfo && \
    tar --directory / -xf /tmp/ncurses.tar \
        $(tar --list -f /tmp/ncurses.tar | grep -E 'libncursesw?\.so.*') && \
    rm -rf /tmp/ncurses.tar

ENV TERMINFO /usr/local/share/terminfo

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make,\
metabarj0/ncurses"
