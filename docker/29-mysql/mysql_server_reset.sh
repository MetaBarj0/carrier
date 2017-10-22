#!/bin/sh

cd /usr/local/mysql

# nuke both configuration and data
rm -rf etc data

# restore minimalistic conf and data
tar -xf configuration.tar
tar -xf data.tar.bz2
