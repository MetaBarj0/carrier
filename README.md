# scripts
various scripts to do various things

- shell/build-gcc-7.2.0-musl.sh : Execute this one on a system having both gcc and musl-libc installed to create a self contained toolchain based on gcc-7.2.0 and the musl-libc that is statically linked. Original work has been made by Jakub Strapko (https://jstrapko.github.io/musl-gcc/)

- docker/busybox\_gcc : a recipe to build a minimalistic image base on busybox and exposing a standalone gcc toolchain statically linked to musl-libc (temporary stuff)
