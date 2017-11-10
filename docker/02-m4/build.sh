#!/bin/sh

# the first arg is the repository name
if [ -z $1 ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

repository=$1

echo 'Building context...'

# build the builder, using a disposable untagged image
image=$(
  docker build \
    -q \
    --build-arg REPOSITORY=$repository \
    -f context/Dockerfile.build-image \
    context | \
  sed 's/sha256://'
)

# launch the build
docker run \
  --rm -it \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  $image

# cleanup the untagged image
docker image prune -f
