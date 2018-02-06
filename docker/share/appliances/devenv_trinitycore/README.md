WHAT?
=====

This is a self contained appliance one can use to contribute to the trinitycore
project : https://www.trinitycore.org/

It is very similar to the devenv\_cpp simpler appliance

# USAGE

Simple. Use the `manage-appliance` script located in the docker/bin/ directory
to spawn the environment. Note however that your system must be bootstrap
beforhand :

  `./manage-appliance start devenv_trinitycore`

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
* metabarj0/boost
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
* metabarj0/mysql
* metabarj0/ninja
* metabarj0/sed
* metabarj0/tar
* metabarj0/vim

## volumes

This appliance have its own set of volumes, respectively :

* devenv\_trinitycore\_.vim
* devenv\_trinitycore\_.ssh
* devenv\_trinitycore\_src
* devenv\_trinitycore\_out
* mysql\_data
* mysql\_conf
* mysql\_mysql-files

When you first run the appliance, volumes are created empty and you have to add
your own set of ssh key, your git configuration as well as your vim
configuration.

mysql volume will be filled with the bare minimum stuff to begin to use mysql as
soon as the mysql service starts for the first time

### devenv\_trinitycore\_.vim

Holds all data for the vim editor to run properly

### devenv\_trinitycore\_.ssh

Contains ssh informations necessary for git to work well

### devenv\_trinitycore\_out

Designed to receive built files.

### devenv\_trinitycore\_src

Volume designed to contains code bases

### mysql\_data

Contains mysql data.

### mysql\_conf

Here are your mysql configuration files

### mysql\_mysql-files

Here are some mysql files
