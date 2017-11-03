FROM metabarj0/docker-cli

COPY flatten-images.sh /usr/local/bin/

ENTRYPOINT [ "check.sh" ]

LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>" \
      requires="metabarj0/docker-cli"
