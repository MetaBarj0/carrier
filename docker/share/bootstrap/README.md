WHAT IS THAT THING?
===================

This is the bootstrap project. It is a mandatory step to complete before
building any further project.
Once successfully built, your docker host will have brand new images that are
considered as foundation prerequisites:

* metabarj0/manifest: This small image will contain a snapshot of all buildable
projects. used by the automatic dependency builder.
* metabarj0/gcc: the GNU Compiler Collection toolchain, able to build both C and
C++ programs.
* metabarj0/make: the make project
* metabarj0/docker-cli: a minimalistic images intended to run container capable
of interacting with your docker host socket
* alpine/wget: The bootstrap fetcher image. This is the fallback fetcher image
to use while the metabarj0/wget image is not built.

HOW TO BUILD?
=============

Building the bootstrap is quite simple and must be done by hand.
First, you need to construct the image using the provided Dockerfile:

`docker build --squash -t my_fancy_bootstrap .`

Note that this command works only if you are in the directory where the
Dockerfile resides and you have enabled experimental feature of you docker
daemon (--squash switch)

The build is fast, because it is only preparation and file copy. Foundation
images are actually build only when you run your brand new bootstrap image.

HOW TO RUN?
===========

Running the image is the final step to obtain foundation images to build further
projects. All you need is an internet connection, a beefy machine and time.
Actually, you will be guided along the run to provide necessary information so
you can just begin by issuing such a command:

`docker run --rm -it my_fancy_bootstrap`

The command above WILL FAIL. But don't worry, for each failure, an explanation
will be given to you to help you to succeed.
At last, a successful command could looks like:

```sh
docker run --rm -it \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -e GCC_VERSION=7.2.0 \
           -e BINUTILS_VERSION=2.29 \
           -e KERNEL_VERSION=4.14.3 \
           -e MAKE_VERSION=4.2 my_fancy_bootstrap
```

Once launched, you can prepare a cup of tea or coffe until it finishes.
It will download a lot of stuff and build a lot of hard stuff.
As a measurment, on an 8 threaded CPU (i7 4980HQ) and 8 Gig of RAM, the build
take approximately 45 minutes (without taking into account the download times)
