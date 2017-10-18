#!/bin/sh

cd /usr/local/mysql

# look for an exisiting configuration, normally, stored in a persistent volume
if [ ! -f etc/my.cnf ]; then
  # no conf found, deploying default one
  tar -xf configuration.tar
fi

# existing data, especially system databases?
if [ ! -d data -o $(ls data | wc -c) -eq 0 ]; then
  # nope! Creating a brand new data load
  tar -xf data.tar.bz2
fi

# starting the beast with provided arguments if any
mysqld "$@"
