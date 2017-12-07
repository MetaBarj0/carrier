#!/bin/sh

# this is the build script of the project. Most of its content is up to you but # the are a couple of rules to observe in order your project build properly.
# This script is really not intended to be run directly by hand but to be used
# by the build system. Therefore, the build system allows you to use some
# internals dynamically added in this script while the project is being built.
# The most important internals added are:
# - package: a function building necessary meta data of this image after it has 
#            been built and allowing it to be used as dependency in further
#            projects
# - packageIncluding: a function working in a similar way as the package
#                     function but allowing the user to specify any file or any
#                     dependecy image to be included in THIS image. Actually
#                     packageIncluding is package on steroids.
# To build a correct build script, follow these guidelines:
# 1- Not mandatory but advise, guard your script with this check:
#    if [ -z $REPOSITORY ]; then
#      echo 'Missing repository name...exiting...'
#      exit 1
#    fi
#    It helps to prevent the execution of this script by hand on a sane
#    environment
#
# 2- Define a MANDATORY PREFIX variable, indicating where the produced built
#    files will reside. Packaging functions (respectively package and
#    packageIncluding need that variable set and pointing to a valid path)
#
# 3- Issue all the command you need to build the project, you have a total
#    control here.
#    
# 4- use either 'package' or 'packageIncluding' depending what you want to
#    include in your image. Such a call MUST be made at the end of the build
#    and take some time, depending what you want to include in your image

# the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# extract sources and prepare for build
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18
mkdir build && cd build

PREFIX=/usr/local

../configure \
  --prefix=$PREFIX \
  --enable-threads=posix \
  --enable-c++ \
  CFLAGS='-O3 -s' \
  CXXFLAGS='-O3 -s'

# Calculates the optimal job count
JOBS=$(cat /proc/cpuinfo | grep processor | wc -l)

# build and install
make -j $JOBS && make install

# make this image a package
package
