#!/bin/sh

# no argument provided, provide shell invocation
if [ ! $1 ]; then
 set -- /bin/sh "$@"
fi

# setup some variable to find toolchain's binaries
TARGET=amd64-linux-musl
COMMAND=${TARGET}-$1

# looks for toolchain's binaries
which $COMMAND 1>&2 1> /dev/null

# if a binary is found, modify script's arguments
if [ $? == 0 ]; then
  # adding necessary stuff for the command to be run without errors
  if [ $1 == 'gcc' -o $1 == 'g++' ]; then
    SYSROOT=/usr/local
    ISYSTEMCPP=${SYSROOT}/include/c++/7.2.0
    ISYSTEMTARGET=${ISYSTEMCPP}/${TARGET}

    COMMAND=${COMMAND}' --sysroot='${SYSROOT}
    COMMAND=${COMMAND}' -isystem '${ISYSTEMCPP}
    COMMAND=${COMMAND}' -isystem '${ISYSTEMTARGET}
  fi

  shift

  set -- "$COMMAND" "$@"
fi

exec $(echo "$@")
