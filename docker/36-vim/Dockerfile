# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as vim_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/vim/vim/archive/master.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/ncurses as ncurses
RUN tar -cf /tmp/ncurses.tar /usr/local/
FROM metabarj0/python2 as python2
RUN tar -cf /tmp/python2.tar /usr/local/
FROM metabarj0/diffutils as diffutils
RUN tar -cf /tmp/diffutils.tar /usr/local/

# intermediate build stage
FROM busybox as vim_build

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
COPY --from=python2 /tmp/python2.tar /tmp/
RUN  tar --directory / -xf /tmp/python2.tar && \
  rm /tmp/python2.tar
COPY --from=diffutils /tmp/diffutils.tar /tmp/
RUN  tar --directory / -xf /tmp/diffutils.tar && \
  rm /tmp/diffutils.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=vim_fetch /tmp/master.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as vim

COPY entrypoint.sh /usr/local/bin/

COPY --from=vim_build /tmp/install/ /usr/local
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=python2 /tmp/python2.tar /tmp/
COPY --from=ncurses /tmp/ncurses.tar /tmp/
COPY --from=diffutils /tmp/diffutils.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar

RUN tar --directory / -xf /tmp/ncurses.tar \
        usr/local/share/terminfo && \
    tar --directory / -xf /tmp/ncurses.tar \
        $(tar --list -f /tmp/ncurses.tar | grep -E 'libncursesw?\.so.*') && \
    rm -rf /tmp/ncurses.tar

RUN tar --directory / -xf /tmp/python2.tar && \
  rm -rf /tmp/python2.tar

RUN tar --directory / -xf /tmp/diffutils.tar && \
  rm -rf /tmp/diffutils.tar

ENV TERMINFO /usr/local/share/terminfo

VOLUME [ "/home/vim/.vim" ]

ENTRYPOINT [ "entrypoint.sh" ]

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/ncurses,\
metabarj0/python2,\
metabarj0/diffutils,\
metabarj0/make"
