# Rocky Linux 9 - Self build icinga2 packages

this project aims at collecting scripts to rebuild icinga2 packages for Rocky Linux 9.

Since icinga2 project decided to lock under a subscription wall packages for RH derivatives I started
searching for an alternative way of getting Icinga2 packages to install on my Rocky Linux 9 monitoring
host.

And this is the result.

Once you have a host with all required packages installed you just simply need to run the 2 scripts
``icinga2-download.sh`` downloads SRPM files (current script use fedora 41 packages)
``icinga2-rebuild.sh`` modifies spec files to kicks off package recompilation
``icinga2-makerepo.sh`` creates repo structure that can be used with yum.


## Notes
Default icinga2 compilation requires ``mysql-devel``, default Rocky Linux package with mysql devel files is ``mariadb-connector-c-devel``
