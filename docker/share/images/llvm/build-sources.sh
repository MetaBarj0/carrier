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

# 1- the repository name must exist in the environment
if [ -z $REPOSITORY ]; then
  echo 'Missing repository name...exiting...'
  exit 1
fi

# 2- define this mandatory variable
PREFIX=/usr/local

# 3- extract sources and prepare for build
# tar commands, configure, make....
EXTRACT_UNSAFE_SYMLINKS=1 \
  tar -xf llvm-5.0.0.src.tar.xz
EXTRACT_UNSAFE_SYMLINKS=1 \
  tar --directory llvm-5.0.0.src/tools/ -xf cfe-5.0.0.src.tar.xz

cd llvm-5.0.0.src/
mkdir build && cd build

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS_RELEASE='-O3 -s'\
  -DCMAKE_EXE_LINKER_FLAGS='-Wl,-rpath,/usr/local/lib/,-rpath,/usr/local/amd64-linux-musl/lib64,-rpath-link,/usr/local/lib/,-rpath-link,/usr/local/amd64-linux-musl/lib64' \
  -DCMAKE_SHARED_LINKER_FLAGS='-Wl,-rpath,/usr/local/lib/,-rpath,/usr/local/amd64-linux-musl/lib64,-rpath-link,/usr/local/lib,-rpath-link,/usr/local/amd64-linux-musl/lib64/' \
  -DLLVM_ENABLE_CXX1Y='ON' -DLLVM_ENABLE_CXX1Z='ON' \
  -G Ninja ..

ninja && ninja install

# create symlinks due to bad design in LLVM about looking for these files
ln -sf \
  /usr/local/lib/gcc/amd64-linux-musl/7.3.0/crtbegin.o \
  /usr/local/lib/crtbegin.o

ln -sf \
  /usr/local/lib/gcc/amd64-linux-musl/7.3.0/crtend.o \
  /usr/local/lib/crtend.o

# removing intermediate compiled python files
rm -rf ${PREFIX}/lib/python3.6

# 4- make this image a package using either package or packageIncluding
# as llvm is built using gcc, including it too
packageIncluding metabarj0/gcc
