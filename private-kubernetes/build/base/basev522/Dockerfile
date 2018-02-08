FROM centos:centos7

LABEL mapr.os=centos7 mapr.version=5.2.2 mapr.mep_version=3.0.1

ENV container docker

# Expose SSH port
EXPOSE 22

# Add service since we are using systemd
COPY mapr-docker.service /etc/systemd/system/mapr-docker.service

# Setup systemd
# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
         /lib/systemd/system \
         -path '*.wants/*' \
         -not -name '*journald*' \
         -not -name '*systemd-tmpfiles*' \
         -not -name '*systemd-user-sessions*' \
         -exec rm \{} \;
RUN systemctl set-default multi-user.target
# Fix zombie problems with pid 1
STOPSIGNAL SIGRTMIN+3

# Add Mapr Repo file for Yum
COPY mapr.repo /etc/yum.repos.d/mapr.repo

# Fix environment
COPY limits.conf /etc/security/limits.conf
COPY 20-nproc.conf /etc/security/limits.d/20-nproc.conf
COPY su /etc/pam.d/su
COPY basestart.sh /opt/mapr/conf/basestart.sh

# Setup repos and dl prereqs + Mapr Core
RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7; \
    rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-7; \
    rpm --import http://package.qa.lab/releases/pub/maprgpg.key; \
    rpm --import http://package.qa.lab/releases/pub/gnugpg.key; \
    yum -y update && yum -y clean all; \
    yum -y install epel-release; \
    sed -i 's/^mirror/#mirror/g' /etc/yum.repos.d/epel.repo; \
    sed -i 's/^#base/base/g' /etc/yum.repos.d/epel.repo; \
    yum install -y sudo wget nfs-utils rpcbind openssh-server openssh-clients \
        java-1.8.0-openjdk-devel mapr-core

# Modify environment for containers
RUN sed -i -e 's/AddUdevRules(list(gdevices));/#AddUdevRules(list(gdevices));/g' /opt/mapr/server/disksetup; \
    chmod +x /opt/mapr/conf/basestart.sh; \
    systemctl disable sshd; \
    systemctl enable mapr-docker.service

CMD ["/bin/bash"]
