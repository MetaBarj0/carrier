#!/bin/sh

set -e

# the first arg is the repository name
if [ -z "$1" ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

repository="$1"

# retag existing image, to keep history
repository_id=$(docker image ls -q "$repository")
if [ ! -z "$repository_id" ]; then
  docker tag "$repository" "$repository"'-'$(date +%Y%m%d%H%M%S)
  docker rmi "$repository"
fi

# the second arg is the caller script directory
if [ -z "$2" ]; then
  echo 'Missing caller script directory path...exiting...'
  exit 1
fi

project_directory="$2"

if [ -z "$3" ]; then
  echo 'Missing base image name...exiting...'
  exit 1
fi

base_image="$3"

# the fourth argument may contain extra Dockerfile commands for the final image
# it is not mandatory
final_extra_dockerfile_commands="$4"

echo 'Building context...'

# build the builder, using a disposable untagged image, relies on the specific
# format output by the docker build command
image=$(
  docker build --squash \
    -q \
    -f ${project_directory}/Dockerfile.build-image \
    ${project_directory} | \
  sed 's/sha256://')

# launch the build
docker run \
  --rm -it \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  -e FINAL_EXTRA_DOCKERFILE_COMMANDS="$final_extra_dockerfile_commands" \
  -e REPOSITORY="$repository" \
  -e BASE_IMAGE="$base_image" \
  $image

# cleanup the untagged images, amongst other potentially
docker image prune -f
