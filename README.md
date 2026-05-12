# Rocky Linux - Self build icinga2 packages

this project aims at collecting scripts to rebuild icinga2 packages for Rocky Linux,
started with version 9 it now works with version 10 as well.

Since icinga2 project decided to lock under a subscription wall packages for RH derivatives I started
searching for an alternative way of getting Icinga2 packages to install on my Rocky Linux 9 monitoring
host.

And this is the result.

Once you have a host with all required packages installed you just simply need to run the 2 scripts <br />
`icinga2-download.sh` downloads SRPM files (current script use fedora 41 packages) <br />
`icinga2-rebuild.sh` modifies spec files to kicks off package recompilation <br />
`icinga2-makerepo.sh` creates repo structure that can be used with yum.


Alternatively, scripts for creating a `Docker` container suitable for rebuilding packages in a self contained environment
are available as well, see README.md in `Docker` tree.


## Notes -- newest first
2026-04: Icinga2 version 2.16 introduce new build system; it now requires `ninja-build` from CRB repository, new feature OPENTELEMETRY require `protobuf-lite`, EL9 patch script disables OPENTELEMETRY because correct build requires version 3.19 of protobuf-lite.

2025-10: Latest version if **icinga-php-thirdparty** require php 8.2 or newer, default php version on RH9 is not good enough, need to install 3rd party version. I'm using remi builds `dnf install http://rpms.remirepo.net/enterprise/remi-release-9.rpm`, `dnf module reset php -y`, `dnf module enable php:remi-8.2 -y` and last `dnf update`, this issue with PHP version does not exist on RH10 based release.

2025-05: Default icinga2 compilation requires `mysql-devel`, default Rocky Linux package with mysql devel files is `mariadb-connector-c-devel`

