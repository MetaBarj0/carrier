#!/bin/sh
set -e

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# error handling
sed -i'' '2i\set -e' build-sources.sh

# insert the source statment for functions.sh, freeing the user to do it
sed -i'' '3i\. ./functions.sh' build-sources.sh

# this script will build a docker image responsible of building sources and
# commit the build result into another docker image for packaging

# build the image an initiate the source build
docker build --squash \
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
FROM $REPOSITORY as package
RUN exportPackageTo /tmp/package

FROM busybox
COPY --from=package /usr/local/bin/exportPackageTo /usr/local/bin/
COPY --from=package /usr/local/bin/importPackageFrom /usr/local/bin/
COPY --from=package /tmp/package /tmp/
COPY --from=package /image.dist /
RUN importPackageFrom /tmp/package
$(echo "$EXTRA_DOCKERFILE_COMMANDS")
LABEL maintainer="metabarj0 <troctsch.cpp@gmail.com>"
EOI

# final clean
docker image prune -f
