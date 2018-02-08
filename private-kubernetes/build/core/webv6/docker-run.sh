#!/bin/sh

docker run -d --hostname web-1 \
  -p 8443:8443 \
  --privileged=true \
  --security-opt seccomp=unconfined \
  --tmpfs /run --tmpfs /run/lock \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v ~/Docker/logs/web:/opt/mapr/logs \
  -v ~/Docker/ssh:/opt/mapr/conf/ssh \
  -v ~/Docker/conf:/opt/mapr/conf/replace \
  -v ~/Docker/cluster:/opt/mapr/conf/cluster \
  --tmpfs /opt/mapr/mapr-cli-audit-log \
  --env-file ./env.list \
  --cap-add=SYS_ADMIN \
  --cap-add=NET_ADMIN \
  --cap-add=NET_BROADCAST \
  --cap-add=SYS_PACCT \
  --cap-add=SYS_NICE \
  --cap-add=SYS_RESOURCE \
  --cap-add=SYS_RAWIO \
  --cap-add=IPC_LOCK \
  --cap-add=SYSLOG \
  --add-host zk-1:172.17.0.3 \
  --add-host cldb-1:172.17.0.4 \
  --add-host mfs-1:172.17.0.5 \
  -t "$*"
