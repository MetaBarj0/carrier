# carrier

Overview
========

Is a sandbox environment and appliance fabricator. It mainly relies on the
`docker` technology therefore, any environment that can natively use `docker`
should be able to use `carrier`.
However, `carrier` can also be used on environment that cannot use `docker`
natively. To operate, `Vagrant` is used alongside `Virtualbox` (as a provider)
to provide a valid docker environment (based on `archlinux`). This installation
provides a pre-configured docker host and docker-compose.
`carrier` can be seen as a solution to facilitate :
- docker image building process
- docker image composition
- docker image reusability
- docker appliance building
- docker appliance execution
- docker appliance persistant storage management (yet to come)

To summarize :

```
+-----------------------------------------------------------+
| carrier                                                   |
+-----------------------------------------------------------+
|                                                           |
| +--------+ } related to image                             |
| | docker | } building, composition                        |
| +--------+ } and reusability                              |
| | images |                                                |
| | …      |                                                |
| |   +----+-----------+ } related to appliance build and   |
| |   | docker-compose | } management as well as containers |
| +---+----------------+ } persistent storages              |
|     | volumes        |                                    |
|     | …              |                                    |
|     +----------------+                                    |
|                                                           |
+-----------------------------------------------------------+
```

## Note for users

`carrier` is under heavy development. It means that several drastic changes
could occur in short period of time leading for instance to a whole
re-architecture of folders, complete rewriting of scripts and spurious feature
changes.

A word on Vagrant and Virtualbox provider
=========================================

One can choose to use the provided `Vagrant` oriented facilities to use
`carrier`. The provided vagrant box is a minimalist `Archlinux` installation
with a particular partition layout. By the way, except for the `/boot` mount
point, all partitions are `LVM2` based. Using `LVM2` ensure a good
scaleability for each related partitions as it allows one to extend volume
groups (system and docker-related) as well as resize up logical volumes (for
instance, one can size up the logical volume used to store `docker` persistent
volumes).

# Designed mount points

- /boot : vfat type, EFI, really small, (64 MB)
- / : LVM2, extendable, (2GB)
- /var/lib/docker : LVM2, extendable, noexec, nodev, nosuid, (8GB)
- /var/lib/docker/volumes : LVM2, extendable, nosuid, (8GB)

# Vagrant shared folders

- /vagrant : classical shared folder created by `Vagrant` itself
- /docker : added mount point pointing on the docker directory of the `carrier`
repository, to facilitate `carrier`'s scripts usage.

Usage
=====

# Creating the working environment using Vagrant facilities

This section describes how to use the `Vagrant` environment provided with the
`carrier` repository. It is not a mandatory step unless you're working on a
platform that does not support `docker` and `docker-compose` natively.
On the other hand, VirtualBox (5.2.6+) and Vagrant (2.0.2+) are needed.

## Setup

Go to the `vagrant/Box4Docker` directory. You'll find a `Vagrantfile` describing
the box.
A simple `vagrant up` should does the job and create a viable environment to
work with.
`vagrant ssh` will allow you to enter the environment's shell and begin to work
with `carrier`.
As stated above, a `/docker` mount point is linked to the `docker/` directory of
the `carrier` repository and ease the `carrier`'s scripts usage.

# Working on existing docker host

Preprequisite : be on an environment where `docker` and `docker-compose` are
supported and installed.
