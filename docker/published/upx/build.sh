#!/bin/sh
tar -xf upx-master.tar.xz
cd upx-master
sed -i -E 's/#!.*/#!\/bin\/sh/g' src/stub/scripts/check_whitespace.sh

CXX='forward-command.sh g++' CXXFLAGS='-O3 -s' make all CHECK_WHITESPACE=/bin/true
mkdir /tmp/install
mv src/upx.out /tmp/install/upx
