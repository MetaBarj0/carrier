# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as gettext_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/gettext/gettext-0.19.8.1.tar.xz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/ncurses as ncurses
RUN tar -cf /tmp/ncurses.tar /usr/local/

# intermediate build stage
FROM busybox as gettext_build

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
COPY --from=gettext_fetch /tmp/gettext-0.19.8.1.tar.xz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as gettext

COPY --from=gettext_build /tmp/install/ /usr/local
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=ncurses /tmp/ncurses.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libgcc_s\.so.*') && \
    tar --directory / -xf /tmp/gcc.tar \
        $(tar --list -f /tmp/gcc.tar | grep -E 'libstdc\+\+\.so.*') && \
    rm -rf /tmp/gcc.tar
RUN tar --directory / -xf /tmp/ncurses.tar \
        $(tar --list -f /tmp/ncurses.tar | grep -E 'libncurses\.so.*') && \
    rm -rf /tmp/ncurses.tar

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make,\
metabarj0/ncurses"
