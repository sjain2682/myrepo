FROM docker.artifactory/maprtech/base:6.00_4.00_001_centos7

# Setup Mapr service ports
EXPOSE 9083 5660 5692 5724 5756

# Copy files for rest of install
COPY start.sh webhcatOk.sh /opt/mapr/server/

RUN chmod +x /opt/mapr/server/start.sh; \
    chmod +x /opt/mapr/server/webhcatOk.sh; \
    yum -y update && yum -y clean all; \
    yum -y install mapr-hivewebhcat mapr-fileserver

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
