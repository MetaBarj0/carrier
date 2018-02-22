#!/bin/sh

set -e

# check provided arguments and initialize some globals helping to build the
# builder image
parseArguments() {
  # the first arg is the repository name
  if [ -z "$1" ]; then
    echo 'Missing repository name...exiting...'
    exit 1
  fi

  REPOSITORY="$1"

  # retag existing image, to keep history
  local repository_id=$(docker image ls -q "$REPOSITORY")
  if [ ! -z "$repository_id" ]; then
    docker tag "$REPOSITORY" "$REPOSITORY"'-'$(date +%Y%m%d%H%M%S)
    docker rmi "$REPOSITORY"
  fi

  # the second arg is the caller script directory
  if [ -z "$2" ]; then
    echo 'Missing caller script directory path...exiting...'
    exit 1
  fi

  PROJECT_DIRECTORY="$2"

  # collect fetch related infos
  SOURCES_FETCH_IMAGE="$3"
  SOURCES_FETCH_COMMAND="$4"
  SOURCES_TARBALL_NAME="$5"

  # collect dependency images, optional
  REQUIRED_IMAGES="$6"

  # to these images, add implicit requirements: gcc and make
  REQUIRED_IMAGES="$(cat << EOI
$REQUIRED_IMAGES
metabarj0/gcc
metabarj0/make
EOI
  )"

  # optional build extra dockerfile commands to add in the generated Dockerfile
  # of the builder image
  BUILD_EXTRA_DOCKERFILE_COMMANDS="$7"

  if [ -z "$8" ]; then
    echo 'Missing base image name...exiting...'
    exit 1
  fi

  BASE_IMAGE="$8"

  # the next argument may contain extra Dockerfile commands for the final image
  # it is not mandatory
  FINAL_EXTRA_DOCKERFILE_COMMANDS="$9"
}

# generate dockerfile instruction for the fetching part
addFetchSection() {
  # verify all needed variables are set
  if [ ! -z "$SOURCES_FETCH_IMAGE" ] \
     && [ ! -z "$SOURCES_FETCH_COMMAND" ] \
     && [ ! -z "$SOURCES_TARBALL_NAME" ]; then
    # verify that the fetch image exists
    local fetch_image_id=$(docker image ls -q "$SOURCES_FETCH_IMAGE")
    if [ -z "$fetch_image_id" ]; then
      error "$(cat << EOI
Error: The image $SOURCES_FETCH_IMAGE does not exist on the docker
host...exiting...
EOI
      )"
      return 1
    fi

    local section_text="$(cat << EOI
FROM $(keyOf $FETCH_IMAGE_ALIAS_PAIR) as \
     $(valueOf $FETCH_IMAGE_ALIAS_PAIR)
WORKDIR /tmp
RUN $SOURCES_FETCH_COMMAND
EOI
)"
    # exposes the section content
    echo "$section_text"
  else
    # unset these vars indicating fetching had not occured
    unset SOURCES_FETCH_IMAGE
    unset SOURCES_FETCH_COMMAND
    unset SOURCES_TARBALL_NAME
  fi
}

# generate part of the build image dockerfile remated to the packaging of
# dependecy images.
addDependenciesPackagingSection() {
  # the generated Dockerfile part text
  local section_text=

  # iterate through the map, building Dockerfile commands
  local build_stage=
  local pair=
  local name=
  local alias=
  for pair in $NAMES_ALIASES_MAP; do
    # extract image name and build stage alias
    name="$(keyOf "$pair")"
    alias="$(valueOf "$pair")"

    # instruction to export the dependency image package
    build_stage="$(cat << EOI
FROM $name as $alias
USER root:root
RUN exportPackageTo /tmp/package
EOI
    )"

    # group these instructions together
    section_text="$(
      append "$section_text" \
             "$build_stage" \
             $'\n'
    )"
  done

  echo "$section_text"
}

# add Dockerfile commands for the final build stage, pretty static, always the
# same commands
addFinalBuildStageSection() {
  # the generated Dockerfile part text
  local section_text="$(cat << EOI
FROM metabarj0/docker-cli
WORKDIR /tmp
COPY build-sources.sh functions.sh ./
COPY exportPackageTo importPackageFrom /usr/local/bin/
ENTRYPOINT [ "/tmp/build-sources.sh" ]
EOI
  )"

  echo "$section_text"
}

# if sources have been fetched, copy them from the fetch image created before
addCopyFetchedSourcesSection() {
  if [ ! -z "$SOURCES_TARBALL_NAME" ]; then
    local section_text="$(cat << EOI
COPY \
  --from=$(valueOf $FETCH_IMAGE_ALIAS_PAIR) \
  /tmp/$SOURCES_TARBALL_NAME \
  ./
EOI
)"

    echo "$section_text"
  fi
}

# if required images have been specified, import them in the final build stage
addDependenciesImportingSection() {
  # the generated Dockerfile part text
  local section_text=

  # iterate through the map, building Dockerfile commands
  local commands=
  local pair=
  local name=
  local alias=
  for pair in $NAMES_ALIASES_MAP; do
    # extract build stage alias
    alias="$(valueOf "$pair")"

    # instruction to export the dependency image package
    commands="$(cat << EOI
COPY --from=$alias /tmp/package ./
RUN importPackageFrom /tmp/package
EOI
    )"

    # group these instructions together
    section_text="$(
      append "$section_text" \
             "$commands" \
             $'\n'
    )"
  done

  echo "$section_text"
}

# make uses of some initialized globals to generate a Dockerfile describing the
# builder image
generateDockerfile() {
  # create a shell variable here as this function is called in this shell,
  # subsequent function calls are executed in sub shells
  if [ ! -z "$SOURCES_FETCH_IMAGE" ]; then
    # make a pair with fetch image and a random generated alias: key is image
    # name, value is alias name. Global accessible through the entire script
    FETCH_IMAGE_ALIAS_PAIR="$(
      makePair "$SOURCES_FETCH_IMAGE" \
               'fetch_'"$(generateRandomBuildStageAlias)"
    )"
  fi

  # another shell variable creation
  NAMES_ALIASES_MAP="$(
    mapImageNamesAndBuildStageAliases "$REQUIRED_IMAGES"
  )"

  cat << EOI > ${PROJECT_DIRECTORY}/Dockerfile.build-sources
$(addFetchSection)
$(addDependenciesPackagingSection)
$(addFinalBuildStageSection)
$(addCopyFetchedSourcesSection)
$(addDependenciesImportingSection)
$BUILD_EXTRA_DOCKERFILE_COMMANDS
EOI
}

# build the builder image and run it, using a specific entrypoint to build the
# project
build() {
  echo 'Building context...'

  # build the builder, using a disposable untagged image, relies on the specific
  # format output by the docker build command
  local image="$(
    docker build --squash \
      -q \
      -f ${PROJECT_DIRECTORY}/Dockerfile.build-image \
      ${PROJECT_DIRECTORY} \
    | sed 's/sha256://')"

  # launch the build
  docker run \
    --rm -it \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    -e REPOSITORY="$REPOSITORY" \
    -e BASE_IMAGE="$BASE_IMAGE" \
    -e FINAL_EXTRA_DOCKERFILE_COMMANDS="$FINAL_EXTRA_DOCKERFILE_COMMANDS" \
    $image

  # cleanup the untagged images, amongst other potentially
  docker image prune -f
}

parseArguments "$@"

. ${PROJECT_DIRECTORY}/functions.sh

generateDockerfile
build
