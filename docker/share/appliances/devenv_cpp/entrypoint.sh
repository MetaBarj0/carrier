#!/bin/sh

if [ -z "$1" ]; then
  set -- sh
fi

exec "$(echo "$@")"
