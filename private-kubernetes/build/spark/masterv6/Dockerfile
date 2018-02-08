FROM docker.artifactory/maprtech/base:6.00_4.00_001_centos7

# Setup Mapr service ports
EXPOSE 22 7077 7337 8080 8081 5660 5692 5724 5756

# Copy files for rest of install
COPY start.sh smasterOk.sh /opt/mapr/server/

RUN chmod +x /opt/mapr/server/start.sh; \
    chmod +x /opt/mapr/server/smasterOk.sh; \
    yum -y update && yum -y clean all; \
    yum -y install mapr-spark-master mapr-fileserver mapr-spark

# Fix Java Classpath Bugs
COPY spark-env.sh /opt/mapr/spark/spark-2.1.0/conf/spark-env.sh
RUN chmod +x /opt/mapr/spark/spark-2.1.0/conf/spark-env.sh

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]
