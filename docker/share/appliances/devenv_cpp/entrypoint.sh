#!/bin/sh

if [ -z "$1" ]; then
  set -- sh
fi

# check the appliance, warn the user if something is missing
if [ ! -f '.ssh/id_rsa' ] \
   || [ ! -f '.ssh/id_rsa.pub' ]; then
  cat << EOI
********************************************************************************
* Warning: Cannot find ssh public or secret key. Note that you need those      *
*          keys in order to operate with git through the SSH protocol.         *
********************************************************************************
EOI
fi

exec "$(echo "$@")"
