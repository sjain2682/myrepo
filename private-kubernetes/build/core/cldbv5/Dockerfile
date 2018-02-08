FROM docker.artifactory/maprtech/base:5.22_3.01_001_centos7

# Setup Mapr service ports
EXPOSE 7222 7221 7220 5660 5692 5724 5756

# Copy files for rest of install
COPY start.sh cldbOk.sh /opt/mapr/server/

RUN chmod +x /opt/mapr/server/start.sh; \
    chmod +x /opt/mapr/server/cldbOk.sh; \
    yum -y update && yum -y clean all; \
    yum -y install mapr-cldb

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
