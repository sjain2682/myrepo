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

FROM centos:centos7
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
    yum install -y java-1.8.0-openjdk-devel mapr-posix-client-basic mapr-posix-client-platinum; \
    mkdir -p /tmp/lib; \
    cp -r /opt/mapr/lib/libfuse.* /tmp/lib; \
    cp -r /opt/mapr/lib/libMapRClient_c.* /tmp/lib; \
    cp -r /opt/mapr/lib/libMapRClient.* /tmp/lib; \
    cp /usr/lib/jvm/jre/lib/amd64/server/libjvm.so /tmp/lib/libjvm.so; \
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
