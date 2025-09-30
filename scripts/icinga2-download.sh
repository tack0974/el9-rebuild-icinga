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

MYOPTS="af:h"
REPOURL=https://packages.icinga.com/fedora
DOWNLOAD_ALL=0
FC=42

function print_help
{
  echo ""
  echo "${1:-} options:"
  echo "    -h: print this help and exit"
  echo "    -a: download all files, default downloads only latest srpm in each directory"
  echo "    -f: overried FC version, default is 41"
  echo ""
}

# Parse args
while getopts "$MYOPTS" myo; do
  case "$myo" in
    a)
      DOWNLOAD_ALL=1
      ;;
    h)
      print_help $0
      exit
      ;;
    f) FC="${OPTARG}"
      ;;
  esac
done

# get repo metadata

curl -s -O ${REPOURL}/${FC}/release/repodata/repomd.xml

XMLFILE=$(basename `cat repomd.xml | grep primary  | grep xml | cut -d \" -f 2`)

curl -s -O ${REPOURL}/${FC}/release/repodata/${XMLFILE}

gzip -cd ${XMLFILE} | grep src.rpm |grep location | cut -d \" -f 2 > files

if [[ "${DOWNLOAD_ALL}" -eq 0 ]] ; then
  # limit file download to in each directory
  FULL_LIST=$(cat files)
  mv files files.orig

  for FNAME in ${FULL_LIST} ; do
    DNAME=$(dirname $FNAME)
    # sort --- get only one, then out to files
    LAST_FILE=$(echo "$FULL_LIST" | sort | grep "$DNAME"/ | tail -1)
    grep $LAST_FILE files > /dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
      echo "$LAST_FILE" >> files
    fi
  done
fi

# download files

cat files | while read line ; do
  DIRNAME=$(dirname $line)
  if [[ ! -d ${FC}/${DIRNAME} ]] ; then
    mkdir -p ${FC}/${DIRNAME}
  fi

  if [[ ! -f ${FC}/$line ]] ; then
    echo "Downloading $line"
    curl -s --output-dir ${FC}/${DIRNAME} -O ${REPOURL}/${FC}/release/$line
  fi
done

rm -f repomd.xml ${XMLFILE} files files.orig
