#!/bin/sh

# 1- the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# not usual way to do things as I don't build anything from sources
# Thus, I call some 'internal' functions not really intended to be used outside
# the functions.sh script, but it does the job

# manual inclusion of what I need, here, symlinks and binaries and metabarj0/gcc
include "$(cat << EOI
/usr/local/bin/clang
/usr/local/bin/clang++
/usr/local/bin/clang-cl
/usr/local/bin/clang-cpp
/usr/local/bin/clang-5.0
/usr/local/lib/crtbegin.o
/usr/local/lib/crtend.o
metabarj0/gcc
EOI
)"

# follow up all symlinks if needed
# resolve all dependencies of that symlink...
collectSharedObjectDependencies

# finalizing the package
finalizePackage
