#!/bin/bash

MYARCH=`uname -m`

if [[ ! -d ~/local/go ]] ; then
  if [[ ! -d ~/local ]] ; then
    mkdir ~/local
  fi
  cd ~/local
  if [[ "$MYARCH" == "x86_64" ]] ; then
    tar xf /incoming/go1.26.2.linux-amd64.tar.gz -C ~/local/
  elif [[ "$MYARCH" == "aarch64" ]] ; then
    tar xf /incoming/go1.26.2.linux-arm64.tar.gz -C ~/local/
  fi
fi

PATH=$PATH:~/local/go/bin

cd ~

if [[ ! -d el9-rebuild-icinga ]] ; then
  git clone https://github.com/tack0974/el9-rebuild-icinga.git
fi

cd el9-rebuild-icinga && git pull
cd scripts
./icinga2-download.sh
./icinga2-rebuild.sh
