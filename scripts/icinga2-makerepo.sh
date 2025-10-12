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

REPO_BASEDIR=~/tmp
GPGSIGN=0

RPMTD=$(rpm --showrc |grep _topdir | grep -v '{_topdir}' | awk '{print $3}')
RPMBUILD_DIR=$(rpm --eval "${RPMTD}")
ELVER=$(rpm --eval "%{rhel}")

function sign_file
{
  MYARG="${1:-}"

  if [[ ${GPGSIGN} -eq 1 ]] && [[ -r "${MYARG}" ]] ; then
    rpm --addsign "${MYARG}"
  fi
}

# Create RPM repo structure, sign RPMs and create
# signature file for repomd.xml

function make_bin_repo
{
  REPODIR=${REPO_BASEDIR}/icinga-repo/${ELVER}
  CREATEINDEX=0

  # find files with icinga in the name
  if [[ -d ${RPMBUILD_DIR}/RPMS ]] ; then
    cd ${RPMBUILD_DIR}/RPMS
    FLIST=$(find . -type f | grep -i icinga)
    # echo $FLIST

    if [[ ! -d ${REPODIR} ]] ; then
      mkdir $REPODIR
    fi

    for i in $FLIST ; do
      if [[ ! -r ${REPODIR}/${i} ]] ; then
        DNAME=$(dirname $i)
        if [[ ! -d ${REPODIR}/${DNAME} ]] ; then
          mkdir -p ${REPODIR}/${DNAME}
        fi
        cp -iv $i ${REPODIR}/${i}
        sign_file ${REPODIR}/${i}
        CREATEINDEX=1
      fi
    done

    if [[ $CREATEINDEX -ne 0 ]] ; then
      echo Create index
      cd ${REPODIR}
      createrepo .
      if [[ ${GPGSIGN} -eq 1 ]] ; then
        gpg --detach-sign --armor repodata/repomd.xml
      fi
    fi
  fi
}

function make_src_repo
{
  # Create SRPM repo structure, sign SPMs and create
  # signature file for repomd.xml

  REPODIR=${REPO_BASEDIR}/icinga-srpm/${ELVER}/Source/
  CREATEINDEX=0
  if [[ -d ${RPMBUILD_DIR}/SRPMS ]] ; then
    cd ${RPMBUILD_DIR}/SRPMS
    FLIST=$(find . -type f | grep -i icinga)

    if [[ ! -d ${REPODIR} ]] ; then
      mkdir -p ${REPODIR}
    fi

    for i in $FLIST ; do
      if [[ ! -r ${REPODIR}/${i} ]] ; then
        DNAME=$(dirname ${i})
        if [[ ! -d ${REPODIR}/${DNAME} ]] ; then
          mkdir -p ${REPODIR}/${DNAME}
        fi
        cp -iv $i ${REPODIR}/${i}
        sign_file ${REPODIR}/${i}
        CREATEINDEX=1
      fi
    done

    if [[ $CREATEINDEX -ne 0 ]] ; then
      echo Create index
      cd ${REPODIR}
      cd ..
      createrepo .
      if [[ ${GPGSIGN} -eq 1 ]] ; then
        gpg --detach-sign --armor repodata/repomd.xml
      fi
    fi
  fi
}

SIGTYPE=$(grep ^%_signature ~/.rpmmacros | awk '{print $2}')

if [[ "${SIGTYPE}" == "gpg" ]] ; then
  GPGSIGN=1
fi

make_bin_repo
make_src_repo
