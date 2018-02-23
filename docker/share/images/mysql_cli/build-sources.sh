#!/bin/sh
# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# not usual way to do things as I don't build anything from sources
# Thus, I call some 'internal' functions not really intended to be used outside
# the functions.sh script, but it does the job

# manual inclusion of what I need, here, symlinks and libs
include '/usr/local/mysql/bin/mysql'

# follow up all symlinks if needed
# resolve all dependencies of that symlink...
collectSharedObjectDependencies

# ncurses used
include '/usr/share/terminfo'

# finalizing the package
finalizePackage
