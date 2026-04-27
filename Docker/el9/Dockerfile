FROM rockylinux:9.7

RUN dnf install -y epel-release

# Enable CRB Repo
RUN crb enable

# Update
RUN dnf update -y

# Install build dependencies
RUN dnf install -y bash rpm-build git \
  make ninja-build cmake flex bison openssl-devel selinux-policy-devel \
  checkpolicy gcc-c++ libedit-devel libstdc++-devel logrotate \
  mariadb-connector-c-devel ncurses-devel postgresql-devel protobuf-lite-devel \
  systemd-devel boost-devel jemalloc-devel tcl which \
  && dnf clean all

# Set up the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
