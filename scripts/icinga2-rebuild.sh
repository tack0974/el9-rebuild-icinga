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

FC="41 42"
GO_REQ_VER="1.24"
MYOPTS="af:h"
BUILD_ALL=0

function print_help
{
  echo ""
  echo "${1:-} options:"
  echo "    -h: print this help and exit"
  echo "    -a: build all versions"
  echo "    -f: overried FC version, default is 41"
  echo ""
}

# Parse args
while getopts "$MYOPTS" myo; do
  case "$myo" in
    a) BUILD_ALL=1
      ;;
    h)
      print_help $0
      exit
      ;;
    f) FC="${OPTARG}"
      ;;
  esac
done

# check go version
go_vers=$(go version | awk '{print $3}' | sed s/go//)
if [[ "${go_vers}" < "${GO_REQ_VER}" ]] ; then
  echo "Found go version ${go_vers}, build require version ${GO_REQ_VER}; upgrade your go version"
  exit 1
fi

for REL in ${FC} ; do

  DIRLIST=$(ls ${REL}/src)
  
  for i in $DIRLIST; do
    if [[ "${BUILD_ALL}" -eq 1 ]] ; then
      # build all package version
      REVLIST=$(ls ${REL}/src/${i})
    else
      # build only latest version
      REVLIST=$(ls ${REL}/src/${i} | sort | tail -n 1)
    fi
  
    # check if srpm package has been already processed successfully
    for LASTREV in $REVLIST ; do
      grep "$LASTREV" completed-${REL} 2>&1 > /dev/null
      if [[ $? -ne 0 ]] ; then
        SRPMNAME=$(echo $LASTREV | sed s/fc${REL}/el9/)
        if [[ ! -r ~/rpmbuild/SRPMS/${SRPMNAME} ]] ; then
          rpm -ivh ${REL}/src/${i}/$LASTREV
  
          SPECFILE=~/rpmbuild/SPECS/${i}.spec
          if [[ -f ${SPECFILE} ]] ; then
            if [[ -x patches/all_specfiles.patch ]] ; then
              echo "APPLY patch patches/all_specfiles.patch"
              patches/all_specfiles.patch ${i} ${REL}
            fi

            if [[ -x patches/${i}.patch ]] ; then
              echo "APPLY patch patches/${i}.patch"
              patches/${i}.patch ${i}
            elif [[ -x patches/${LASTREV}.patch ]] ; then
              echo "APPLY patch patches/${LASTREV}.patch"
              patches/${LASTREV}.patch ${i}
            fi

            rpmbuild -ba ${SPECFILE}
            if [[ $? -ne 0 ]] ; then
              exit
            else
              echo "`date +'%Y-%m-%d %H:%M:%S'`: $LASTREV" >> completed-${REL}
            fi
          fi
        else
          echo "`date +'%Y-%m-%d %H:%M:%S'`: $LASTREV" >> completed-${REL}
        fi
      fi
    done
  done
done
