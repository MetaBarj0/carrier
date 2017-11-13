#!/bin/sh

# grab the build script from the build tools
CURRENT_DIRECTORY=$(pwd -P)
cd $(dirname $0)
SCRIPT_DIRECTORY=$(pwd -P)
BUILD_TOOLS_DIRECTORY=$SCRIPT_DIRECTORY/../01-build-tools
cd $CURRENT_DIRECTORY

# this image require some extra commands (environment vars, volumes...)
EXTRA_DOCKERFILE_COMMANDS=$(cat << EOI
ENV TERMINFO /usr/local/share/terminfo
EOI
)

exec \
  $BUILD_TOOLS_DIRECTORY/build.sh \
  metabarj0/ncurses \
  $SCRIPT_DIRECTORY \
  "$EXTRA_DOCKERFILE_COMMANDS"
