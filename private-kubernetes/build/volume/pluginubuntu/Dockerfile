FROM golang:latest
RUN apt-get update; \
    apt-get install golang-glide
COPY maprfs/github.com /go/src/github.com
COPY maprfs/vendor /go/src/maprfs/vendor
COPY maprfs/glide.yaml /go/src/maprfs/glide.yaml
COPY maprfs/glide.lock /go/src/maprfs/glide.lock
COPY maprfs/main.go /go/src/maprfs/main.go
WORKDIR /go/src/maprfs
#RUN glide install -v
RUN go build

FROM ubuntu:latest
LABEL mapr.os=ubuntu
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
# Add Mapr Repo file for Apt
COPY mapr.list /etc/apt/sources.list.d/mapr.list
# Setup repos and dl prereqs + Mapr Core
RUN apt-get update; \
    apt-get install -y apt-utils sudo lsb-release; \
    DEBIAN_FRONTEND=noninteractive apt-get install --allow-unauthenticated -y openjdk-8-jdk mapr-posix-client-basic mapr-posix-client-platinum; \
    systemctl enable mapr-docker.service; \
    systemctl disable mapr-posix-client-basic; \
    systemctl disable mapr-posix-client-platinum; \
    mkdir -p /tmp/lib; \
    cp -r /opt/mapr/lib/libfuse.* /tmp/lib; \
    cp -r /opt/mapr/lib/libMapRClient_c.* /tmp/lib; \
    cp -r /opt/mapr/lib/libMapRClient.* /tmp/lib; \
    cp /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/libjvm.so /tmp/lib/libjvm.so; \
    rm -rf /opt/mapr/contrib; \
    rm -rf /opt/mapr/conf.new; \
    rm -rf /opt/mapr/examples; \
    rm -rf /opt/mapr/hadoop; \
    rm -rf /opt/mapr/initscripts; \
    rm -rf /opt/mapr/include; \
    rm -rf /opt/mapr/libexp; \
    rm -rf /opt/mapr/lib; \
    rm -rf /opt/mapr/logs; \
    rm -rf /opt/mapr/pid; \
    rm -rf /opt/mapr/server; \
    mkdir -p /opt/mapr/lib; \
    cp -r /tmp/lib/* /opt/mapr/lib; \
    rm -rf /tmp

# Use Small Image
FROM alpine:latest
# Add bash
RUN apk add --no-cache bash
# Copy MapR files
COPY --from=1 /opt/mapr /opt/mapr
# Copy script files
COPY copy-plugin /opt/mapr/plugin/copy-plugin
COPY start-fuse /opt/mapr/plugin/start-fuse
COPY pre-stop /opt/mapr/plugin/pre-stop
# Build GO code
COPY --from=0 /go/src/maprfs/maprfs /opt/mapr/plugin/maprfs
RUN chmod +x /opt/mapr/plugin/copy-plugin; \
    chmod +x /opt/mapr/plugin/pre-stop; \
    chmod +x /opt/mapr/plugin/start-fuse; \
    chmod +x /opt/mapr/plugin/maprfs; \
    touch /opt/mapr/plugin/RELEASE; \
    ts=`stat -c %Y /opt/mapr/plugin/RELEASE`; \
    echo "$ts" > /opt/mapr/plugin/RELEASE
WORKDIR /opt/mapr/plugin/
CMD ["bash -c /opt/mapr/plugin/copy-plugin"]
