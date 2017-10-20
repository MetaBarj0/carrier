#!/bin/sh
set -e

# filtering on user input
images=
for arg in "$@"; do
  images="$images $(docker image ls --format='{{.Repository}}' | grep $arg)"
done

# each corresponding image will be flattened
if [ ! -z "$images" ]; then
  for image in $images; do
    # creating a container take only the last layer of an image, hence, after
    # the container is created, export it as a new image having the same
    # repository of the source one, removing all of its history. Finally,
    # delete the created container
    cid=$(docker create $image)
    docker export $cid | docker import - $image
    docker rm $cid
  done
fi
