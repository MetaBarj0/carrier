FROM busybox

MAINTAINER troctsch <troctsch.cpp@gmail.com>

COPY amd64-linux-musl.tar.xz install.sh forward-command.sh /tmp/

RUN /tmp/install.sh

ENTRYPOINT [ "/usr/local/bin/forward-command.sh" ]
