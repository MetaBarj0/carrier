#!/bin/sh

# the first arg is the repository name
if [ -z $1 ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

repository=$1

echo 'Building context...'

# grab common stuff in build tools, a dockerfile and scripts
CURRENT_DIRECTORY=$(pwd -P)
cd $(dirname $0)
SCRIPT_DIRECTORY=$(pwd -P)
BUILD_TOOLS_DIRECTORY=$SCRIPT_DIRECTORY/../01-build-tools
cd $CURRENT_DIRECTORY
cp $BUILD_TOOLS_DIRECTORY/Dockerfile.build-image \
   $BUILD_TOOLS_DIRECTORY/functions.sh \
   $BUILD_TOOLS_DIRECTORY/build-image.sh context

# build the builder, using a disposable untagged image
image=$(
  docker build \
    -q \
    --build-arg repository=$repository \
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

# cleanup common build tools
rm -f context/Dockerfile.build-image \
      context/build-image.sh \
      context/functions.sh
