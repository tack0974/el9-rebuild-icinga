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

FC="41"
GO_REQ_VER="1.24"

# check go version
go_vers=$(go version | awk '{print $3}' | sed s/go//)
if [[ "${go_vers}" < "${GO_REQ_VER}" ]] ; then
  echo "Found go version ${go_vers}, build require version ${GO_REQ_VER}; upgrade your go version"
  exit 1
fi

for REL in ${FC} ; do

  DIRLIST=$(ls ${REL}/src)
  
  for i in $DIRLIST; do
    # build all package version
    REVLIST=$(ls ${REL}/src/${i})
  
    # check if package is already installed
    for LASTREV in $REVLIST ; do
      grep "$LASTREV" completed-${REL} 2>&1 > /dev/null
      if [[ $? -ne 0 ]] ; then
        rpm -ivh ${REL}/src/${i}/$LASTREV
  
        SPECFILE=~/rpmbuild/SPECS/${i}.spec
        if [[ -f ${SPECFILE} ]] ; then
          # Patch and rebuild
          sed -i s/fc${REL}/el9/g ~/rpmbuild/SPECS/${i}.spec
          sed -i s/'_topdir.BUILD[a-z\.0-9/\-]*BUILDROOT'/'{buildroot}'/g ~/rpmbuild/SPECS/${i}.spec
          if [[ ${i} == "icinga2" ]] ; then
            sed -i s/mysql-devel/mariadb-connector-c-devel/ ~/rpmbuild/SPECS/${i}.spec
          fi
  
          if [[ ${i} == "icingadb-redis" ]] ; then
            sed -i  s/BUILD.icingadb-redis.*-build\'/BUILD\'/  ~/rpmbuild/SPECS/${i}.spec
            sed -i  s,'/usr/lib/rpm/rpmuncompress -x -v','tar xvf',  ~/rpmbuild/SPECS/${i}.spec
            # continue
          fi
  
          rpmbuild -ba ${SPECFILE}
          if [[ $? -ne 0 ]] ; then
            exit
          else
            echo "$LASTREV" >> completed-${REL}
          fi
        fi
      fi
    done
  done
done
