# Podman

Introducing new option for building RPM using container.

Need to have working podman on the system, directory tree for file persistence


# Step by step (written and tested on Rocky Linux 9)
* Download GO release tarfile (version `1.26.2`) downloaded and available in `~/mypodman/in`
* Create persistent root directory for package build and file download (example is for EL9) `RHEL=9 mkdir -p ~/mypodman/$(uname -m)/el${RHEL}/root`
* Create podman image `./image_build.sh`
* Download source and rebuild rpm package using `./run_docker.sh`
* RPM files are available in `~/mypodman/$(uname -m)/el9/root/rpmbuild/RPMS/` tree

That's it.
