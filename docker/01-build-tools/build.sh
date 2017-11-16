#!/bin/sh

set -e

# the first arg is the repository name
if [ -z "$1" ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

repository="$1"

# retag existing image
repository_id=$(docker image ls -q "$repository")
if [ ! -z "$repository_id" ]; then
  docker tag "$repository" "$repository"$(date +%Y%m%d%H%M%S)
  docker rmi "$repository"
fi

# the second arg is the caller script directory
if [ -z "$2" ]; then
  echo 'Missing caller script directory path...exiting...'
  exit 1
fi

caller_script_directory="$2"

# the third argument may contain extra Dockerfile commands for the final image
# it is not mandatory
extra_dockerfile_commands="$3"

echo 'Building context...'

# grab common stuff in build tools, a dockerfile and scripts
CURRENT_DIRECTORY=$(pwd -P)
cd $(dirname $0)
SCRIPT_DIRECTORY=$(pwd -P)
BUILD_TOOLS_DIRECTORY=$SCRIPT_DIRECTORY/../01-build-tools
cd $CURRENT_DIRECTORY
cp $BUILD_TOOLS_DIRECTORY/Dockerfile.build-image \
   $BUILD_TOOLS_DIRECTORY/functions.sh \
   $BUILD_TOOLS_DIRECTORY/exportPackageTo \
   $BUILD_TOOLS_DIRECTORY/importPackageFrom \
   $BUILD_TOOLS_DIRECTORY/build-image.sh \
   ${caller_script_directory}/context

# build the builder, using a disposable untagged image
image=$(
  docker build --squash \
    -q \
    --build-arg REPOSITORY=$repository \
    -f ${caller_script_directory}/context/Dockerfile.build-image \
    ${caller_script_directory}/context | \
  sed 's/sha256://'
)

# launch the build
docker run \
  --rm -it \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  -e EXTRA_DOCKERFILE_COMMANDS="$extra_dockerfile_commands" \
  $image

# cleanup the untagged images
docker image prune -f

# cleanup common build tools
rm -f ${caller_script_directory}/context/Dockerfile.build-image \
      ${caller_script_directory}/context/build-image.sh \
      ${caller_script_directory}/context/exportPackageTo \
      ${caller_script_directory}/context/importPackageFrom \
      ${caller_script_directory}/context/functions.sh
