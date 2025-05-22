#! /bin/bash

# (C) Copyright 2025 Davide Tacchella
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.  If not, see
# <https://www.gnu.org/licenses/>.

set -u

REPOURL=https://packages.icinga.com/fedora
FC=41

# get repo metadata

curl -s -O ${REPOURL}/${FC}/release/repodata/repomd.xml

XMLFILE=$(basename `cat repomd.xml | grep primary  | grep xml | cut -d \" -f 2`)

curl -s -O ${REPOURL}/${FC}/release/repodata/${XMLFILE}

gzip -cd ${XMLFILE} | grep src.rpm |grep location | cut -d \" -f 2 > files

# download files

cat files | while read line ; do
  DIRNAME=$(dirname $line)
  if [[ ! -d ${FC}/${DIRNAME} ]] ; then
    mkdir -p ${FC}/${DIRNAME}
  fi

  if [[ ! -f ${FC}/$line ]] ; then
    curl -s --output-dir ${FC}/${DIRNAME} -O ${REPOURL}/${FC}/release/$line
  fi
done

rm repomd.xml ${XMLFILE} files
