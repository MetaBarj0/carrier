WHAT?
=====

This directory contains all docker related stuff. It allows one to build both
images and appliances. Following is a description of each directory and what
they contain :

HOW?
====

Pretty simple. First and mandatory : bootstrap your environment. Then, do what
you want (create your very own image or appliance, build existing image or
appliance...) using scripts under the bin/ directory

## bootstrapping

The bootstrap process consist in building the bare minimum to continue ti use
carrier on your system. For more details, take a look at the README.md file
located in share/bootstrap directory.

DETAILS:
========

This section describes some details about how things are organized.

## bin/

This directory contains all script directly executable by the user. You can
bootstrap the environment, build images and build appliances using respective
scripts :
* bootstrap.sh
* manage-image.sh
* manage-appliance.sh

## lib/

This directory contains tooling (scripts, docker files...) used by scripts
located in the bin/ directory. Such a tooling is used to manage both images and
appliances.

## share/

This directory contains all images and appliances that system can build.
Moreover, the bootstrap project has its own directory. There also is a template
subdirectory that contains skeleton files to help to build either an image or an
appliance.
Ideally, this directory will contain all new images and appliances you could
create.

### share/bootstrap

Contains all necessary stuff to bootstrap your environment and going any further
in image building or appliance composing. Remember that to bootstrap your
environment, you have to use the `bootstrap.sh` script located in the bin/
directory.

### share/templates

Contains skeleton files to help in image building and appliance composing.
The image subdirectory contains the bare minimum needed to build a new image.
The appliance directory contains the bare minimum to build an appliance.

### share/image

Contains all existing images that can be built on your system. Feel free to add
as many images as you want to extend your environment capabilities!

### share/appliances

Contains all existing composable appliances that can be run on your system. Feel
free to add as many appliances as you want to extend your environment capabilities!
