#!/bin/bash

if [ ! -S /var/run/docker.sock ]; then
  cat << EOI
--------------------------------------------------------------------------------
Hey! This bootstrap project requires that you bind-mount the docker socket from
your host machine to this freshly created container. Next time you'll start this
container, specify the '-v' flag of the 'run' command just like this :
'docker run -v /var/run/docker.sock:/var/run/docker.sock'.
Bye!
--------------------------------------------------------------------------------
EOI
  exit 1
fi

# verifying environment before start
if [ ! $GCC_VERSION ]; then
  cat << EOI
--------------------------------------------------------------------------------
Hey! You didn't specify a version for GCC!
Next time you'll start this container, specify the '-e' flag of the 'run'
command for instance, 'docker run -e GCC_VERSION=7.2.0'. Note that version other
than 7.2.0 are not supported yet.
Bye!
--------------------------------------------------------------------------------
EOI
  exit 1
fi

if [ ! $BINUTILS_VERSION ]; then
  cat << EOI
--------------------------------------------------------------------------------
Hey! You didn't specify a version for binutils!
Next time you'll start this container, specify the '-e' flag of the 'run'
command for instance, 'docker run -e BINUTILS_VERSION=2.29'. Note that needed
version of binutils depends on gcc version you want.
Bye!
--------------------------------------------------------------------------------
EOI
  exit 1
fi

# get the version needed from environment
if [ ! $KERNEL_VERSION ]; then
  cat << EOI
--------------------------------------------------------------------------------
Hey! You didn't specify a version for the Linux kernel!
Next time you'll start this container, specify the '-e' flag of the 'run'
command for instance, 'docker run -e KERNEL_VERSION=4.12.12'. Note that only 4.x
version are supported for now.
Bye!
--------------------------------------------------------------------------------
EOI
  exit 1
fi

# update the system and install necessary packages
pacman -Syu --noconfirm gcc make wget file git lzip docker

TARGET=amd64-linux-musl

cd

mkdir -p $TARGET

cd $TARGET

echo downloading gcc-${GCC_VERSION} sources...
wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz

echo downloading binutils-${BINUTILS_VERSION} sources...
wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz

echo downloading linux-${KERNEL_VERSION} sources...
wget https://ftp.gnu.org/gnu/linux-libre/4.x/${KERNEL_VERSION}-gnu/linux-libre-${KERNEL_VERSION}-gnu.tar.lz

# grab musl-libc
echo downloading musl-libc-1.1.16 sources...
wget http://www.musl-libc.org/releases/musl-1.1.16.tar.gz

# grab the build script
echo downloading the build script...
wget https://raw.githubusercontent.com/MetaBarj0/scripts/master/shell/build-gcc-${GCC_VERSION}-musl.sh
chmod +x build-gcc-${GCC_VERSION}-musl.sh

# extract sources
lzip -d linux-libre-${KERNEL_VERSION}-gnu.tar.lz
find . -maxdepth 1 -type f ! -name '*.sh' ! -exec tar -xf {} \;
rm -f *.tar*

# download gcc prerequisites
cd gcc-${GCC_VERSION}
./contrib/download_prerequisites

cd ..

# build the toolchain!
./build-gcc-${GCC_VERSION}-musl.sh

# do some cleanup
find . -maxdepth 1 ! -name ${TARGET} ! -name . -exec rm -rf {} \;

echo packing the toolchain...
tar -cf ${TARGET}.tar $TARGET
rm -rf $TARGET
xz -z9e -T 0 ${TARGET}.tar

# grab docker files to create the gcc image
for f in {Dockerfile,install.sh,forward-command.sh}; do
  wget https://raw.githubusercontent.com/Metabarj0/scripts/master/docker/busybox_gcc/$f
done
chmod +x install.sh forward-command.sh

# if an old metabarj0/builder repository exists, delete it
REPOSITORY=$(docker images metabarj0/builder -q)

if [ $REPOSITORY ]; then
  docker rmi $REPOSITORY
fi

# create the container builder, containing the gcc toolchain based on busybox and static musl
echo Building metabarj0/builder image...
docker build -t metabarj0/builder .

# the test source file
cat << EOI > test.cpp
#include <iostream>

int main( int, char *[] )
{
  std::cout << "metabarj0/builder looks healthy!" << std::endl;

  return 0;
}
EOI

# a dockerfile to build a container for build testing and run testing
cat << EOI > Dockerfile.test
FROM metabarj0/builder as build
COPY test.cpp" /tmp/
RUN forward-command.sh g++ -std=c++1z /tmp/test.cpp -o /tmp/test.out
FROM busybox as run
COPY --from build /tmp/test.out /tmp/test.out
RUN /tmp/test.out
EOI

# create a multi stage build container to build an executable and run it
docker build -t busybox/test -f Dockerfile.test .

echo Testing the toolchain...
docker run --rm busybox/test
result=$?

# remove persistent stuff
docker rmi busybox/test

if [ $result != 0 ]; then
cat << EOI
--------------------------------------------------------------------------------
Oops! Something went wrong either during the build process or the produced
binary file testing. Please, contact the maintainer of this crappy project to
get things fixed : troctsch.cpp@gmail.com.
Very sorry! :'(
--------------------------------------------------------------------------------
EOI
  exit 1
fi
