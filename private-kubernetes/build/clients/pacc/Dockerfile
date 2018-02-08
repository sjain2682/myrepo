FROM docker.artifactory/maprtech/pacc:5.2.2_3.0.1_centos7_yarn_fuse_hbase_hive_pig_spark_streams

# Add service since we are using systemd
COPY mapr-docker.service /etc/systemd/system/mapr-docker.service
# Copy files for rest of install
COPY start.sh paccOk.sh /opt/mapr/server/

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

RUN chmod +x /opt/mapr/server/paccOk.sh; \
    chmod +x /opt/mapr/server/start.sh; \
    systemctl enable mapr-docker.service

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
