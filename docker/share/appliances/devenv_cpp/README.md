WHAT?
=====

This is a self contained appliance one can use to develop c++ projects.
It is composed with following images :

* metabarj0/bash
* metabarj0/cmake
* metabarj0/coreutils
* metabarj0/ctags
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

This appliance have its own set of volumes, respectively :

* devenv\_cpp\_.vim
* devenv\_cpp\_.ssh
* devenv\_cpp\_src
* devenv\_cpp\_out

When you first run the appliance, volumes are created empty and you have to add
your own set of ssh key, your git configuration as well as your vim
configuration

# devenv\_cpp\_.vim

Holds all data for the vim editor to run properly

# devenv\_cpp\_.ssh

Contains ssh informations necessary for git to work well

# devenv\_cpp\_out

Designed to receive built files.

# devenv\_cpp\_src

Volume designed to contains code bases
