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
for f in /usr/local/lib64/libcrypto.so*; do
  echo $f >> /image.dist
done

for f in /usr/local/lib64/libssl.so*; do
  echo $f >> /image.dist
done

# follow up all symlinks if needed
# resolve all dependencies of that symlink...
collectSharedObjectDependencies

# then, include directories
include '/usr/local/include/openssl'
include '/usr/local/lib64/engines'

# finalizing the package
finalizePackage
