# WIP : 02-unique-script

Overview
========

This directory contains the essence of `carrier`, providing all stuff related to
`docker` technology.
This directory contains folders looking like a classical linux file system:

- `bin/` directory contains executable entities
- `lib/` directory contains common stuff used by binaries for instance
- `share/` directory acts as a repository categorizing files of `carrier`'s
features :
  - `share/images/` directory that contains one directory by docker image
`carrier` supports and can build and manage
  - `share/appliances/` directory that contains one directory by docker-compose
appliance `carrier` can build and manage
  - `share/bootstrap/` directory that contains all bootstrap related stuff.
- `tmp/` directory is a temporary staging area used by the build process of both
images and appliances. Should you find any file or directory within, you can
safely delete it if not any image or appliance is being built.
