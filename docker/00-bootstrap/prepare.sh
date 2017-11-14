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

# check the asked version
if [ ! -f /tmp/build-gcc-${GCC_VERSION}-musl.sh ]; then
  echo 'Sorry, the gcc version you requested in not (yet) supported.'
  echo 'Please, send an email to the maintainer of the project to ask'
  echo 'for a support for this specific version. If he is in a good mood'
  echo 'you could obtain what you are looking for!'
  echo '<troctsch.cpp@gmail.com>'
  echo 'Bye!'
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

# get the version needed from environment, make
if [ ! $MAKE_VERSION ]; then
  cat << EOI
--------------------------------------------------------------------------------
Hey! You didn't specify a version for the 'make' utility!
Next time you'll start this container, specify the '-e' flag of the 'run'
command for instance, 'docker run -e MAKE_VERSION=4.2'.
Bye!
--------------------------------------------------------------------------------
EOI
  exit 1
fi

# update the system and install necessary packages
pacman -Syu --noconfirm --needed \
  gcc make wget file lzip docker unzip bison

TARGET=amd64-linux-musl

cd /tmp

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

# extract sources
lzip -d linux-libre-${KERNEL_VERSION}-gnu.tar.lz
find . -maxdepth 1 -type f ! -name '*.sh' ! -exec tar -xf {} \;
rm -f *.tar*

# download gcc prerequisites
cd gcc-${GCC_VERSION}
./contrib/download_prerequisites

# build the toolchain!
cp /tmp/build-gcc-${GCC_VERSION}-musl.sh /tmp/$TARGET/build-gcc-${GCC_VERSION}-musl.sh
/tmp/$TARGET/build-gcc-${GCC_VERSION}-musl.sh

# do some cleanup
rm -rf /tmp/${TARGET}
cd /tmp

# fixing path in *.la files targeting the tmp build directory
for f in $(find /usr/local -name '*.la' -exec grep -H 'tmp' {} \; | sed 's/:.*//'); do
  sed -i'' 's/\/tmp\/amd64-linux-musl\/build-amd64-linux-musl/\/usr\/local/g' $f
done

echo packing the toolchain...
PREFIX=/usr/local/
tar -cf ${TARGET}.tar $PREFIX
xz -z9e -T 0 ${TARGET}.tar
rm -rf $PREFIX

# if an old metabarj0/gcc repository exists, delete it
REPOSITORY=$(docker images metabarj0/gcc -q)

if [ $REPOSITORY ]; then
  docker rmi $REPOSITORY
fi

# creating the exportPackageTo script to be used in metabarj0/gcc image
cat << EOI > exportToPackage
#!/bin/sh

if [ -z "\$1" ]; then
  echo 'Expecting a destination for the package...exiting...'
  exit 1
fi

package_directory="\$(dirname "\$1")"
package_file_name="\$(basename "\$1")"

mkdir -p "\$package_directory"

# create a tar archive in destination, no more, no less
tar \
  -cf "\$package_directory"/"\$package_file_name" \
  --no-recursion \
  \$(cat /image.dist)
EOI
chmod +x exportToPackage

# create the container gcc, containing the gcc toolchain based on busybox and static musl
echo Building metabarj0/gcc image...
docker build --squash -t metabarj0/gcc -f Dockerfile.gcc .

# the test source file
cat << EOI > test.cpp
#include <iostream>

// c++17 feature
namespace a::very::nested::one {}

int main( int, char *[] )
{
  // c++11 feature
  std::cout << R"_(metabarj0/gcc looks healthy!)_" << std::endl;

  // c++14 feature
  return ( []( auto ){ return 0; } )( 42 );
}
EOI

# a dockerfile to build a container for build testing and run testing
cat << EOI > Dockerfile.test
FROM metabarj0/gcc as build
COPY test.cpp /tmp/test.cpp
RUN g++ -std=c++1z /tmp/test.cpp -O3 -s -static -o /tmp/test.out
FROM busybox as run
COPY --from=build /tmp/test.out /tmp/test.out
RUN /tmp/test.out
EOI

# create a multi stage build container to build an executable and run it
docker build --squash -t busybox/test -f Dockerfile.test .

echo Testing the toolchain...
docker run --rm busybox/test
result=$?

# remove persistent stuff and dangling images built from stages
docker rmi busybox/test
docker image prune -f

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

# creating a 'make' image
echo 'Downloading make '$MAKE_VERSION'...'
wget https://ftp.gnu.org/gnu/make/make-${MAKE_VERSION}.tar.bz2

cat << EOI > build-make.sh
#!/bin/sh
set -e
cd /tmp
tar -xf make-${MAKE_VERSION}.tar.bz2
cd make-${MAKE_VERSION}
mkdir build
cd build
../configure --prefix=/tmp/make-${MAKE_VERSION}/install CFLAGS='-O3 -s -static' --build='amd64-linux-musl'
./build.sh
./make install

cd /tmp/make-${MAKE_VERSION}/install
tar -cf /tmp/make.tar .
tar --list -f /tmp/make.tar | sed -r 's/^\./usr\/local/' > /tmp/image.dist
EOI

chmod +x build-make.sh

cat << EOI > Dockerfile.make
FROM metabarj0/gcc as builder
COPY make-${MAKE_VERSION}.tar.bz2 build-make.sh /tmp/
RUN /tmp/build-make.sh
FROM busybox
COPY exportPackageTo /usr/local/bin/
COPY --from=builder /tmp/make.tar /tmp/
COPY --from=builder /tmp/image.dist /
RUN mkdir -p /usr/local && tar --directory /usr/local -xf /tmp/make.tar && rm -f /tmp/make.tar
EOI

# if an old metabarj0/make repository exists, delete it
REPOSITORY=$(docker images metabarj0/make -q)

if [ $REPOSITORY ]; then
  docker rmi $REPOSITORY
fi

docker build --squash -t metabarj0/make -f Dockerfile.make .

# last, create a simplistic docker client container
cat << EOI > entrypoint.sh
#!/bin/sh
if [ ! -S /var/run/docker.sock ]; then
  echo 'Oops! It looks like you did not bind-mounted the docker socket in this neat container!'
  echo 'Next time you use the 'docker run' command, do not forget to use the '-v' switch like :'
  echo 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock'
  echo 'for example...'
  echo 'Bye!'
  exit 1
fi

# no argument provided, provide shell invocation
if [ ! \$1 ]; then
 set -- /bin/sh "\$@"
fi

exec \$(echo "\$@")
EOI

chmod +x entrypoint.sh

cat << EOI > Dockerfile.docker-cli
FROM alpine as docker
RUN apk add --no-cache docker
RUN tar -cf /tmp/docker.tar /usr/bin/docker /lib/ld-musl-x86_64.so.1 /lib/libc.musl-x86_64.so.1

FROM busybox as docker-cli
RUN mkdir -p /usr/bin/

WORKDIR /tmp/

COPY --from=docker /tmp/docker.tar ./
RUN tar --directory / -xf docker.tar && \
    rm -f docker.tar

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

LABEL maintainer "Metabarj0 <troctsch.cpp@gmail.com>"
EOI

# if an old metabarj0/docker-cli repository exists, delete it
REPOSITORY=$(docker images metabarj0/docker-cli -q)

if [ $REPOSITORY ]; then
  docker rmi $REPOSITORY
fi

docker build --squash -t metabarj0/docker-cli -f Dockerfile.docker-cli .

# removing dangling images
docker image prune -f
