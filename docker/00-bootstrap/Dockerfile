FROM base/archlinux

LABEL maintainer="Metabarj0 <troctsch.cpp@gmail.com>"

WORKDIR /tmp
COPY prepare.sh build-gcc-7.2.0-musl.sh Dockerfile.gcc install.sh ./

ENTRYPOINT ./prepare.sh
