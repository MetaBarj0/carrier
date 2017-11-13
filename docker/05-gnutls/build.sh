#!/bin/sh

# grab the build script from the build tools
CURRENT_DIRECTORY=$(pwd -P)
cd $(dirname $0)
SCRIPT_DIRECTORY=$(pwd -P)
BUILD_TOOLS_DIRECTORY=$SCRIPT_DIRECTORY/../01-build-tools
cd $CURRENT_DIRECTORY

exec $BUILD_TOOLS_DIRECTORY/build.sh metabarj0/gnutls $SCRIPT_DIRECTORY
