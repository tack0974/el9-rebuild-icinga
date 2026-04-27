#! /bin/bash

ARCH=$(uname -m)

podman run -v ~/mypodman/in:/incoming -v ~/mypodman/${ARCH}/el10/root:/root build-el10:latest
