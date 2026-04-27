#! /bin/bash

ARCH=`uname -m`

podman run -v ~/mypodman/in:/incoming -v ~/mypodman/${ARCH}/el9/root:/root build-el9:latest
