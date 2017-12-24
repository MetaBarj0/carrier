# create packages with needed components
FROM metabarj0/vim as vim
RUN exportPackageTo /tmp/vim

FROM metabarj0/ctags as ctags
RUN exportPackageTo /tmp/ctags

FROM metabarj0/coreutils
RUN exportPackageTo /tmp/coreutils

# importing packages in a blank image
FROM busybox

COPY --from=vim /tmp/vim /tmp/
RUN importPackageFrom /tmp/vim

COPY --from=ctags /tmp/ctags /tmp/
RUN importPackageFrom /tmp/ctags

COPY --from=coreutils /tmp/coreutils /tmp/
RUN importPackageFrom /tmp/coreutils

COPY run_forever.sh /usr/local/bin/

ENTRYPOINT [ "entrypoint.sh", "/usr/local/bin/run_forever.sh" ]
