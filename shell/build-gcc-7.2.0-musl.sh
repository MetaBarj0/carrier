#!/bin/bash

### original work : Jakub Strapko (https://jstrapko.github.io/musl-gcc/)

# Download GCC source code, only version 6.1.0 and higher support musl target
# Download binutils source code
# Download musl source code
# Download Linux source code
# Create working directory for example mkdir $HOME/musl
# Extract all downloaded source codes to this directory
# Make sure that working directory does NOT contain anything except extracted source codes (No tarred archives, we will be using wildcards for directory names)
# Go to extracted GCC source code and run ./contrib/download_prerequisites

## Create musl standalone compiler : works with gcc-7.2.0
## Custom Optimizations
OPT='-O3 -mtune=generic -fPIC'

## Number of threads
WORKERS=$(wc -l <<< $(grep processor <<< $(cat /proc/cpuinfo)))
if [ ! $WORKERS ]; then
  WORKERS=1;
fi

## Arch short designation (amd64 not recognized by musl)
ARCH='x86_64'
## Arch full designation; must end with -musl 
TARGET='amd64-linux-musl'

## End of user defined variables
export PREFIX="$(pwd)/build-$TARGET"
export CFLAGS="$OPT -w -s"
export CXXFLAGS="$OPT -w -s"
export PATH="$PREFIX/bin:$PATH"

## Abort on error
set -e

## Clean if exists
rm -rf "$PREFIX"
mkdir -p "$PREFIX"

echo Working...

## Fix path to usr inside $PREFIX
cd "$PREFIX"
ln -nfs . usr
cd ..

## Build temp musl
rm -rf build-musl
mkdir build-musl
cd build-musl
CROSS_COMPILE=" " ../musl*/configure --prefix="$PREFIX" --target="$ARCH" 1>/dev/null
make -j$WORKERS 1>/dev/null
make install 1>/dev/null
cd ..
rm -rf build-musl
echo "1/7 musl done."

## Build temp binutils
rm -rf build-binutils
mkdir build-binutils
cd build-binutils
../binutils*/configure --prefix="$PREFIX" --target="$TARGET" --enable-gold=yes --disable-bootstrap 1>/dev/null
make -j$WORKERS 1>/dev/null
make install 1>/dev/null
cd ..
rm -rf build-binutils
echo "2/7 BINUTILS done."

## Build temp gcc
rm -rf build-gcc
mkdir build-gcc
cd build-gcc
../gcc*/configure \
  --prefix="$PREFIX" --target="$TARGET" --enable-gold=yes --enable-lto \
  --with-sysroot="$PREFIX" --disable-multilib --disable-libsanitizer \
  --enable-languages=c,c++ 1>/dev/null
make -j$WORKERS 1>/dev/null
make install 1>/dev/null
cd ..
rm -rf build-gcc
echo "3/7 GCC done."

## Fix paths
export CC="$TARGET-gcc"
export CXX="$TARGET-g++"

export PREFIX=/usr/local/
export CFLAGS="$CFLAGS --sysroot="$PREFIX""
export CXXFLAGS="$CXXFLAGS --sysroot="$PREFIX""

## Clean existing
rm -rf "$PREFIX"

## Create linux headers
cd linux*
make ARCH="$ARCH" INSTALL_HDR_PATH="$PREFIX" headers_install 1>/dev/null
make clean 1>/dev/null
cd ..
echo "4/7 LINUX headers done."

## Fix usr path
cd "$PREFIX"
ln -nfs . usr
cd /tmp/$TARGET

## Build final musl
rm -rf build-musl
mkdir build-musl
cd build-musl
CROSS_COMPILE="$TARGET-" ../musl*/configure --prefix="$PREFIX" --target="$ARCH" --syslibdir="$PREFIX/lib" 1>/dev/null
make -j$WORKERS 1>/dev/null
make install 1>/dev/null
cd ..
rm -rf build-musl
echo "5/7 musl done."

## Build final binutils
rm -rf build-binutils
mkdir build-binutils
cd build-binutils
../binutils*/configure --prefix="$PREFIX" --target="$TARGET" --enable-gold=yes --disable-bootstrap 1>/dev/null
make -j$WORKERS 1>/dev/null
make install 1>/dev/null
cd ..
rm -rf build-binutils
echo "6/7 BINUTILS done."

## Build final gcc
rm -rf build-gcc
mkdir build-gcc
cd build-gcc
../gcc*/configure \
  --prefix="$PREFIX" --target="$TARGET"  --enable-gold=yes --enable-lto \
  --with-sysroot="$PREFIX" --disable-multilib --disable-libsanitizer \
  --enable-languages=c,c++ --libexecdir="$PREFIX/lib" 1>/dev/null
make -j$WORKERS 1>/dev/null
make install 1>/dev/null
cd ..
rm -rf build-gcc

echo "7/7 GCC done."
echo All done.
