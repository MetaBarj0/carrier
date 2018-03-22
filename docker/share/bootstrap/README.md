Overview
========

This directory contains all files that are necessary to use the bootstrap
domain correctly with `carrier`

## Note

Bootstrapping your system is a mandatory step required to build any of
`carrier` image

To bootstrap your system, just run :
`<carrier_directory>/bin/carrier bootstrap run`
and grab a couple cups of tea/coffee.

As a measurment, on an 8 threaded CPU (i7 4980HQ) and 8 Gig of RAM, the build
take approximately 45 minutes (without taking into account the download times)
This measurment used a the recommended Vagrant you can build with `carrier`
