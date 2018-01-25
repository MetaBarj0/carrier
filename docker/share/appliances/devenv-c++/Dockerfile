# This is the Dockerfile responsible of the appliance construction using exsting
# docker images on the docker host.
# It is fairly simple and gather all required image packages then, extract them
# in a busybox image that will be the appliance image

# all these images will be gathered into the appliance
FROM metabarj0/gcc as gcc
RUN exportPackageTo /tmp/gcc

FROM metabarj0/make as make
RUN exportPackageTo /tmp/make

FROM metabarj0/coreutils as coreutils
RUN exportPackageTo /tmp/coreutils

FROM metabarj0/ctags as ctags
RUN exportPackageTo /tmp/ctags

FROM metabarj0/gdb as gdb
RUN exportPackageTo /tmp/gdb

FROM metabarj0/git as git
RUN exportPackageTo /tmp/git

FROM metabarj0/ninja as ninja
RUN exportPackageTo /tmp/ninja

FROM metabarj0/vim as vim
RUN exportPackageTo /tmp/vim

# appliance base image
FROM busybox

# boilerplate...think about generate the dockerfile...actually
WORKDIR /tmp
COPY importPackageFrom /usr/local/bin/

COPY --from=gcc /tmp/gcc ./
COPY --from=make /tmp/make ./
COPY --from=coreutils /tmp/coreutils ./
COPY --from=ctags /tmp/ctags ./
COPY --from=gdb /tmp/gdb ./
COPY --from=git /tmp/git ./
COPY --from=ninja /tmp/ninja  ./
COPY --from=vim /tmp/vim  ./

RUN importPackageFrom /tmp/gcc
RUN importPackageFrom /tmp/make
RUN importPackageFrom /tmp/coreutils
RUN importPackageFrom /tmp/ctags
RUN importPackageFrom /tmp/gdb
RUN importPackageFrom /tmp/git
RUN importPackageFrom /tmp/ninja
RUN importPackageFrom /tmp/vim

WORKDIR /

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
