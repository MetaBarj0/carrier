FROM base/archlinux

WORKDIR /tmp
COPY prepare.sh \
     build-gcc-7.2.0-musl.sh \
     build-gcc-7.3.0-musl.sh \
     exportPackageTo \
     functions.sh \
     importPackageFrom \
     ./

ENTRYPOINT ./prepare.sh

LABEL maintainer="Metabarj0 <troctsch.cpp@gmail.com>"
