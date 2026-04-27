# Podman

Introducing new option for building RPM using container.

Need to have working podman on the system, directory tree for file persistence

Scripts provided expects following things:
* GO release tarfile (version `1.26.2`) downloaded and available in `~/mypodman/in`
* Persistent root directory for package build and file download in `~/mypodman/${ARCH}/elXX/root`
** using separate directories for Architecture (x86_64, aarch64) and Distribution release (el9, el10)
