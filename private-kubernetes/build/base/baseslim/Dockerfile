FROM centos:centos7

LABEL mapr.os=centos7 mapr.version=6.0.0 mapr.mep_version=4.0

ENV container docker

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

# Setup repos and dl prereqs + Mapr Core
RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7; \
    rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-7; \
    rpm --import http://package.qa.lab/releases/pub/maprgpg.key; \
    rpm --import http://package.qa.lab/releases/pub/gnugpg.key; \
    yum -y update && yum -y clean all; \
    yum -y install epel-release; \
    sed -i 's/^mirror/#mirror/g' /etc/yum.repos.d/epel.repo; \
    sed -i 's/^#base/base/g' /etc/yum.repos.d/epel.repo; \
    yum install -y curl initscripts net-tools sudo wget which java-1.8.0-openjdk-devel mapr-client

COPY basestart.sh /opt/mapr/conf/basestart.sh

# Modify environment for containers
RUN chmod +x /opt/mapr/conf/basestart.sh; \
    systemctl enable mapr-docker.service

CMD ["/bin/bash"]
