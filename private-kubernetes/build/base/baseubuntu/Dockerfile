FROM ubuntu:latest

LABEL mapr.os=ubuntu mapr.version=5.2.2 mapr.mep_version=3.0.1

ENV container docker
ENV NOTVISIBLE "in users profile"
ENV DEBIAN_FRONTEND "noninteractive"

# Expose SSH port
EXPOSE 22

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

COPY limits.conf /etc/security/limits.conf
COPY su /etc/pam.d/su
COPY basestart.sh /opt/mapr/conf/basestart.sh

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BFDDB60966B3F0D6

COPY mapr.list /etc/apt/sources.list.d/mapr.list

RUN apt-get update; \
    apt-get install -y apt-utils sudo wget curl tar python net-tools iputils-ping iputils-arping iputils-tracepath sudo wamerican lsb-release
RUN apt-get install -y libpangocairo-1.0-0 openssh-server openssh-clients
RUN apt-get install -y openjdk-8-jdk
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mapr-core

# Modify environment for containers
RUN sed -i -e 's/AddUdevRules(list(gdevices));/#AddUdevRules(list(gdevices));/g' /opt/mapr/server/disksetup
RUN chmod +x /opt/mapr/conf/basestart.sh
#RUN systemctl disable sshd
#RUN systemctl enable mapr-docker.service

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash"]
