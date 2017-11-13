#!/bin/sh

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# this script will build a docker image responsible of building sources and
# commit the build result into another docker image for packaging

# build the image an initiate the source build
docker build \
  -t $REPOSITORY \
  -f Dockerfile.build-sources .

# intermediate clean
docker image prune -f

# run the image binding the docker socket and forwarding REPOSITORY environment
# variable
docker run --rm -it \
	   -v /var/run/docker.sock:/var/run/docker.sock \
	   -e REPOSITORY=$REPOSITORY \
           $REPOSITORY

# build the final image using the repository name. Relies on what has been
# built and the file /image.dist containing all the files to package
# repository name is dynamic. Extra dockerfile commands may be added
cat << EOI | docker build --squash -t $REPOSITORY -
FROM $REPOSITORY as tarball
RUN tar -cf /tmp/package.tar /image.dist \$(cat /image.dist)

FROM busybox
COPY --from=tarball /tmp/package.tar /tmp
RUN tar --directory / -xf /tmp/package.tar && \
    rm -f /tmp/package.tar
$(echo "$EXTRA_DOCKERFILE_COMMANDS")
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
EOI

# final clean
docker image prune -f
