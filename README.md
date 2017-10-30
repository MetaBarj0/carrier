# scripts

This is a repository of scripts for various program. So far, `docker` and `vagrant` are concerned.

First, you must have `vagrant 2.0` and virtual box 5.1+ installed on you host machine.

You can modify the virtual machine configuration as you like in the Vagrantfile, especially the part about
processor and memory reservations.

Then, go to the vagrant/Box4Docker directory and type : `vagrant up`.
It'll download the box and create a brand new virtual archlinux virtual machine in virtualbox ready to work with docker.

Feel free to install additional programs in the box if you need, for instance, `git` could be useful.

Next, go into your vagrant virtual machine with `vagrant ssh` and find out a way to get the this `scripts` git
repository inside the virtual machine either :

- by using `git` : `git clone git@github.com:MetaBarj0/scripts.git`.
- by using virtual box shared folder capabilities, copying the repo into the shared folder
- by using any other method you like

Then, go to the `scripts/docker` folder and build manually the bootstrap image (this is the 00-bootstrap project).
This project will build the bare minimum to build other images, it will create a docker 3 images containing :

- a working gcc toolchain (only the 7.2.0 is supported for now) with c and c++ language activated linked against the
  `musl-libc`
- a working make
- a working docker designed to work with your docker host, this is not docker in docker but docker aside docker

To build the bootstrap image, you could do that :
`cd docker/00-bootstrap`
`docker build --squash -t bootstrap .`
`docker run --rm -it <<...>> bootstrap` (<<...>> being various options you must specify to build the aforementionned 3
images), the run command will tell you what is missing and guide you to provide the right stuff then, if everything is
good, the bootstrap construction will go.

Grab one or two (or more) cup of coffee/tea, it'll take some time to build gcc, make and docker images.

Once it's done, verify you have your 3 docker images, then, you can proceed building the rest with :

`../build_all.sh`

It will build every project located in the `docker folder`

Obviously you can build project one by one using only a build command from docker cli for instance :
`cd 02-m4`
`docker build --squash -t m4 .`
It'll build a fully functional self embedded working m4 docker image