#! /bin/bash

set -u
set -e

CURDIR=`pwd`

podman build ${CURDIR} -t build-el10
