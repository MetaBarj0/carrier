WHAT?
=====

This is a self contained appliance one can use to develop c++ projects.
One that is familiar with cmake, gcc, vim git, gdb could find this appliance
useful.

# USAGE

Simple. Use the `manage-appliance` script located in the docker/bin/ directory
to spawn the environment. Note however that your system must be bootstrap
beforhand :

  `./manage-appliance start devenv_cpp`

Taking a just bootstrapped system, it will build absolutely everything you need
to start your environment.

# configuration

It's up to you. You will need to provided git configuration, ssh keys, ssh
config and vim files.

## A piece of advice

This appliance require to build the llvm (to potentially allow a vim user to
use YouCompleteMe). It is a really greedy project, both in build time and in
memory usage. Make sure to allocate enough RAM before building this project or
it could fail near the end (the Sema project of the llvm is a monster)

# COMPOSITION

## images

* metabarj0/bash
* metabarj0/cmake
* metabarj0/coreutils
* metabarj0/ctags
* metabarj0/gawk
* metabarj0/gcc
* metabarj0/gdb
* metabarj0/git
* metabarj0/less
* metabarj0/libclang
* metabarj0/make
* metabarj0/ninja
* metabarj0/sed
* metabarj0/tar
* metabarj0/vim

## volumes

This appliance have its own set of volumes, respectively :

* devenv\_cpp\_.vim
* devenv\_cpp\_.ssh
* devenv\_cpp\_src
* devenv\_cpp\_out

When you first run the appliance, volumes are created empty and you have to add
your own set of ssh key, your git configuration as well as your vim
configuration

### devenv\_cpp\_.vim

Holds all data for the vim editor to run properly

### devenv\_cpp\_.ssh

Contains ssh informations necessary for git to work well

### devenv\_cpp\_out

Designed to receive built files.

### devenv\_cpp\_src

Volume designed to contains code bases
