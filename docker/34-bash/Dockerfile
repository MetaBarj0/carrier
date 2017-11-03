# fetching sources using a prebuilt wget from alpine, wget in busybox will be
# built later
FROM metabarj0/wget as bash_fetch
WORKDIR /tmp
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/bash/bash-4.4.12.tar.gz

# intermediate stage to get toolchain files for the build. Using an intermediate
# tarball to keep symlinks and don't follow them
FROM metabarj0/gcc as gcc
RUN tar -cf /tmp/gcc.tar /usr/local/ /lib/
FROM metabarj0/make as make
RUN tar -cf /tmp/make.tar /usr/local/
FROM metabarj0/ncurses as ncurses
RUN tar -cf /tmp/ncurses.tar /usr/local/
FROM metabarj0/gettext as gettext
RUN tar -cf /tmp/gettext.tar /usr/local/
FROM metabarj0/m4 as m4
RUN tar -cf /tmp/m4.tar /usr/local/

# intermediate build stage
FROM busybox as bash_build

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
COPY --from=gettext /tmp/gettext.tar /tmp/
RUN  tar --directory / -xf /tmp/gettext.tar && \
  rm /tmp/gettext.tar
COPY --from=m4 /tmp/m4.tar /tmp/
RUN  tar --directory / -xf /tmp/m4.tar && \
  rm /tmp/m4.tar

# copy sources and build script then, execute the build script
WORKDIR /tmp
COPY --from=bash_fetch /tmp/bash-4.4.12.tar.gz .
COPY build.sh .
RUN ./build.sh

# final stage, copy the result in a busybox image
FROM busybox as bash

COPY --from=bash_build /usr/local/bin/bash /usr/local/bin/bashbug /usr/local/bin/
COPY --from=gcc /tmp/gcc.tar /tmp/
COPY --from=ncurses /tmp/ncurses.tar /tmp/

RUN tar --directory / -xf /tmp/gcc.tar \
        lib/ \
        usr/local/lib/libc.so && \
    rm -rf /tmp/gcc.tar

RUN tar --directory / -xf /tmp/ncurses.tar \
        $(tar --list -f /tmp/ncurses.tar | grep -E 'libncurses\.so.*') && \
    rm -rf /tmp/ncurses.tar

ENTRYPOINT [ "/usr/local/bin/bash", "-l" ]

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/gcc,\
metabarj0/wget,\
metabarj0/make,\
metabarj0/ncurses,\
metabarj0/gettext,\
metabarj0/m4"
