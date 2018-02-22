#!/bin/sh

set -e

checkEnvironment() {
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
command for instance, 'docker run -e GCC_VERSION=7.2.0'. Note that versions
7.2.0 and 7.3.0 are supported so far.
Bye!
--------------------------------------------------------------------------------
EOI
    exit 1
  fi

  # check the asked version
  if [ ! -f /tmp/build-gcc-${GCC_VERSION}-musl.sh ]; then
    cat << EOI
--------------------------------------------------------------------------------
Sorry, the gcc version you requested in not (yet) supported.  Please, send an
email to the maintainer of the project to ask for a support for this specific
version. If he is in a good mood you could obtain what you are looking for!
<troctsch.cpp@gmail.com>
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
}

updateEnvironment() {
  # update the system and install necessary packages
  pacman -Syu --noconfirm --needed \
    gcc make wget file lzip docker unzip bison

  # saving state to accelerate future uses
  docker commit \
    $(hostname) \
    $(docker ps --filter id=$(hostname) --format='{{.Image}}')
}

createManifestDockerImage() {
  # idiot script that run forever, allowing a container continue running in
  # detached mode to exec stuff inside
  cat << EOI > run_forever
#!/bin/sh
while true; do
  sleep 10
done
EOI
  chmod +x run_forever

  # script to update the manifest
  cat << EOI > update
#!/bin/sh
cd /tmp
wget https://github.com/MetaBarj0/carrier/archive/master.tar.gz
tar -xf master.tar.gz carrier-master/docker && rm -f master.tar.gz
mv carrier-master/docker /
rm -f /docker.tar.bz2
tar -cf /docker.tar /docker
rm -rf /docker
bzip2 -9 /docker.tar
rm -rf carrier-master
EOI
  chmod +x update

  cat << EOI > Dockerfile.manifest
FROM busybox
COPY run_forever update /bin/
RUN update
ENTRYPOINT run_forever
EOI

  # if an old metabarj0/manifest repository exists, delete it
  REPOSITORY=$(docker images metabarj0/manifest -q)

  if [ $REPOSITORY ]; then
    docker rmi $REPOSITORY
  fi

  docker build --squash -t metabarj0/manifest -f Dockerfile.manifest .

  docker image prune -f

  rm -rf Dockerfile.manifest run_forever update
}

setupDirectories() {
  TARGET=amd64-linux-musl
  cd /tmp
  mkdir -p $TARGET
}

downloadSources() {
  cd $TARGET

  echo downloading gcc-${GCC_VERSION} sources...
  wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz

  echo downloading binutils-${BINUTILS_VERSION} sources...
  wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz

  echo downloading linux-${KERNEL_VERSION} sources...
  wget https://ftp.gnu.org/gnu/linux-libre/4.x/${KERNEL_VERSION}-gnu/linux-libre-${KERNEL_VERSION}-gnu.tar.lz

  # grab musl-libc
  echo downloading musl-libc-1.1.18 sources...
  wget http://www.musl-libc.org/releases/musl-1.1.18.tar.gz
}

extractSources() {
  # extract sources
  lzip -d linux-libre-${KERNEL_VERSION}-gnu.tar.lz
  find . -maxdepth 1 -type f ! -name '*.sh' ! -exec tar -xf {} \;
  rm -f *.tar*
}

downloadGccPrerequisites() {
  # download gcc prerequisites
  cd gcc-${GCC_VERSION}
  ./contrib/download_prerequisites
}

buildToolchain() {
  cp /tmp/build-gcc-${GCC_VERSION}-musl.sh \
    /tmp/$TARGET/build-gcc-${GCC_VERSION}-musl.sh

  # build the toolchain!
  /tmp/$TARGET/build-gcc-${GCC_VERSION}-musl.sh 1> /dev/null
}

cleanupAndFixPaths() {
  rm -rf /tmp/${TARGET}
  cd /tmp

  # fixing path in *.la files targeting the tmp build directory
  for f in $(find /usr/local -name '*.la' -exec grep -H 'tmp' {} \; | sed 's/:.*//'); do
    sed -i'' 's/\/tmp\/amd64-linux-musl\/build-amd64-linux-musl/\/usr\/local/g' $f
  done
}

packToolchain() {
  PREFIX=/usr/local/
  tar -cf ${TARGET}.tar $PREFIX
  xz -z9e -T 0 ${TARGET}.tar
  rm -rf $PREFIX
}

buildGccImage() {
  # if an old metabarj0/gcc repository exists, delete it
  REPOSITORY=$(docker images metabarj0/gcc -q)

  if [ $REPOSITORY ]; then
    docker rmi $REPOSITORY
  fi

  # script to install the built gcc image
  cat << EOI > install.sh
#!/bin/sh

cd /tmp

# move and cleanup libraries
EXTRACT_UNSAFE_SYMLINKS=1 tar -xf amd64-linux-musl.tar.xz --directory / && \
  rm /tmp/amd64-linux-musl.tar.xz

# fix links necessary for the dynamic loader to work
ln -sf /usr/local/lib/libc.so /usr/local/lib/ld-musl-x86_64.so.1
mkdir -p /lib
cp -P /usr/local/lib/ld-musl-x86_64.so.1 /lib/

cd /usr/local/bin

# create a bunch of handful aliases
for f in amd64-linux-musl-*; do
  target=\$(echo \$f | sed 's/amd64-linux-musl-//g')
  if [ ! -f \$target ]; then
    ln -s \$f \$target
  fi
done

# create the image.dist file using file installed in /usr/local and the link
# created in /lib; excluding import, export package feature
find /usr/local \
  ! -name importPackageFrom \
  ! -name exportPackageTo \
| sed 's/\.\///' > /image.dist

echo '/lib/ld-musl-x86_64.so.1' >> /image.dist
EOI
  chmod +x install.sh

  # dockerfile to build the gcc image
  cat << EOI > Dockerfile.gcc
FROM busybox
COPY amd64-linux-musl.tar.xz install.sh /tmp/
COPY exportPackageTo importPackageFrom /usr/local/bin/
RUN /tmp/install.sh && \
    rm -f /tmp/install.sh
EOI

  # create the gcc image, containing the gcc toolchain based on busybox and musl
  docker build --squash -t metabarj0/gcc -f Dockerfile.gcc .
}

testGccImage() {
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
}

createMakeImage() {
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
tar --list -f /tmp/make.tar | sed -E 's/^\./\/usr\/local/' > /tmp/image.dist
EOI
  chmod +x build-make.sh

  cat << EOI > Dockerfile.make
FROM metabarj0/gcc as builder
COPY make-${MAKE_VERSION}.tar.bz2 build-make.sh /tmp/
RUN /tmp/build-make.sh
FROM busybox
COPY exportPackageTo importPackageFrom /usr/local/bin/
COPY --from=builder /tmp/make.tar /tmp/
COPY --from=builder /tmp/image.dist /
RUN mkdir -p /usr/local \
    && tar --directory /usr/local -xf /tmp/make.tar && rm -f /tmp/make.tar
EOI

  # if an old metabarj0/make repository exists, delete it
  REPOSITORY=$(docker images metabarj0/make -q)

  if [ $REPOSITORY ]; then
    docker rmi $REPOSITORY
  fi

  docker build --squash -t metabarj0/make -f Dockerfile.make .
}

createFetcherImage() {
  cat << EOI | docker build -t alpine/wget -
FROM alpine
RUN apk add --no-cache wget
EOI
}

createDockerCliImage() {
  cat << EOI > entrypoint.sh
#!/bin/sh
if [ ! -S /var/run/docker.sock ]; then
  cat << EOI_
Oops! It looks like you did not bind-mounted the docker socket in this neat
container! Next time you use the 'docker run' command, do not forget to use the
'-v' switch like : docker run --rm -v /var/run/docker.sock:/var/run/docker.sock
for example...
Bye!
EOI_
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
RUN tar -cf \
      /tmp/docker.tar \
      /usr/bin/docker \
      /lib/ld-musl-x86_64.so.1 \
      /lib/libc.musl-x86_64.so.1 \
      /usr/lib/libltdl.so*

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
}

checkEnvironment
updateEnvironment
createManifestDockerImage
setupDirectories
downloadSources
extractSources
downloadGccPrerequisites
buildToolchain
cleanupAndFixPaths
packToolchain
buildGccImage
testGccImage
createMakeImage
createFetcherImage
createDockerCliImage
