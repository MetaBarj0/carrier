#!/bin/bash

# build all images except the bootstrap that must be constructed manually

# get this script directory and file name, in case it is executed out of his parent directory
pushd $(dirname $0) > /dev/null

script_dir=$(pwd -P)
script_name=$(basename $0)

script=${script_dir}/${script_name}

popd > /dev/null

# browse each image directory in order and then, build each image
for d in $(sort <<< "$(find $script_dir -type d -maxdepth 1 ! -name 00-bootstrap ! -name docker ! -name .)"); do
  # get only the last part of the directory path
  image_name=$(basename $d)
  # replace numerical order by the repository owner
  image_name=$(sed -E 's/[0-9]{2}-(.+)/metabarj0\/\1/' <<< $image_name)

  # finally, build the image
  docker build --squash -t $image_name $d
  
  # cleanup stuff
  docker rm $(docker ps -aq)
  docker image prune -f
done