# carrier

WHAT IS THAT
============

`carrier` is a repository containing build script. Small space used for a big intelligence.
More seriously, it allow the user to construct his own development environment using 2
different technologies that are Docker and Vagrant.

WHY DID YOU DO THAT?
====================

Why not? I always wanted to have such a tooling to work on my projects and not be bound to any platform.
Now I can.

`carrier` has the following philosophy: Autonomy, Composability, Usability and Simplicity.

HOW TO USE IT?
==============

This is a repository of scripts for various program. So far, `docker` and `vagrant` are concerned.

First, you must have `vagrant 2.0` and virtual box 5.1+ installed on you host machine.
The constraint of Virtualbox exists because so far, I provide only a a Vagrant box witht the virtual box provider

You can modify the virtual machine configuration as you like in the Vagrantfile, especially the part about
processor and memory reservations.

You can even use any box of your choice as soon as the installed OS can run Docker.

Then, go to the vagrant/Box4Docker directory and type : `vagrant up`.
It'll download the box and create a brand new virtual archlinux virtual machine in virtualbox ready to work with docker.

Feel free to install additional programs in the box if you need, for instance, `git` could be useful.

Next, go into your vagrant virtual machine with `vagrant ssh` and find out a way to get this `carrier` git
repository inside the virtual machine either :

- by using `git` : `git clone git@github.com:MetaBarj0/scripts.git`.
- by using virtual box shared folder capabilities, copying the repo into the shared folder
- by using any other method you like

Then, go to the `docker` folder and build manually the bootstrap image (this is the 0-bootstrap project).
This project will build the bare minimum to build other images, it will create 4 docker images containing :

- a `manifest` image, internally used to build other ones
- a working gcc toolchain (only the 7.2.0 is supported for now) with c and c++ language activated linked against the
  `musl-libc`
- a working make
- a working docker client designed to work with your docker host, this is not docker in docker but docker aside docker

To build the bootstrap image please, refer to the `README` file in its directory.

Grab one or two (or more) cup of coffee/tea, it'll take some time to build all resultant images.

Once it's done, verify you have your 4 docker images, then, you can proceed building the rest.
Please read the README file in 1-projects to learn how to achieve that.
