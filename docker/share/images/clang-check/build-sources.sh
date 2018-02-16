#!/bin/sh

# 1- the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# not usual way to do things as I don't build anything from sources
# Thus, I call some 'internal' functions not really intended to be used outside
# the functions.sh script, but it does the job

# manual inclusion of what I need
include /usr/local/bin/clang-check

# follow up all symlinks if needed
# resolve all dependencies of that symlink...
collectSharedObjectDependencies

# finalizing the package
finalizePackage
