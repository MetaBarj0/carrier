#!/bin/sh

if [ -z "$1" ]; then
  set -- sh
fi

# exploit and cleanup sensible environment data

exec "$(echo "$@")"
