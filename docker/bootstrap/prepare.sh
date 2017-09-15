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

# create the container builder, containing the gcc toolchain based on busybox and static musl
echo Building metabarj0/builder image...
docker build -t metabarj0/builder .

# Create a test, just to see if everything is good
# a volume that will receive a test source file
docker volume create test

# the test source file
cat << EOI > test.cpp
#include <iostream>

int main( int, char *[] )
{
  std::cout << "metabarj0/builder looks healthy!" << std::endl;

  return 0;
}
EOI

# a dockerfile to build a container for build testing
cat << EOI > Dockerfile.test.build
FROM busybox
VOLUME [ "/test" ]
COPY [ "test.cpp", "/test/" ]
EOI

# Build the testing container aiming to populate the volume
docker build -t busybox/test.build -f Dockerfile.test.build .
docker run --rm --mount type=volume,source=test,destination=/test busybox/test.build

# run a metabarj0/builder container to compile the test file and create an executable in the volume
docker run --rm --mount type=volume,source=test,destination=/test metabarj0/builder g++ -std=c++1z /test/test.cpp -o /test/test.out

if [ $? != 0 ]; then
cat << EOI
--------------------------------------------------------------------------------
Oops! Something went wrong during the build process. Please, contact the
maintainer of this crappy project to get things fixed : troctsch.cpp@gmail.com.
Very sorry! :'(
--------------------------------------------------------------------------------
EOI
  # remove persistent stuff
  docker rmi busybox/test.build
  docker volume rm test

  exit 1
fi

# remove test remainings that are persistent
docker rmi busybox/test.build

# a dockerfile to build a container for run testing of the produced binary
cat << EOI > Dockerfile.test.run
FROM busybox
VOLUME [ "/test" ]
CMD mv /test/test.out /tmp && \
    /tmp/test.out
EOI

# Build the testing container aiming to execute the produced binary
docker build -t busybox/test.run -f Dockerfile.test.run .

echo Testing the produced testing binary file...
docker run --rm --mount type=volume,source=test,destination=/test busybox/test.run

if [ $? != 0 ]; then
cat << EOI
--------------------------------------------------------------------------------
Oops! Something went wrong during the testing of the produced binary. Please,
contact the maintainer of this crappy project to get things fixed :
troctsch.cpp@gmail.com.
Very sorry! :'(
--------------------------------------------------------------------------------
EOI
  # remove persistent stuff
  docker rmi busybox/test.run
  docker volume rm test

  exit 1
fi

# remove test remainings that are persistent
docker rmi busybox/test.run
docker volume rm test
