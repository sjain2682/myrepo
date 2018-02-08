#!/bin/sh

docker run -d \
  --hostname zk-1 \
  -p 5181:5181 -p 2888:2888 -p 3888:3888 \
  --privileged=true \
  --security-opt seccomp=unconfined \
  --tmpfs /run --tmpfs /run/lock \
  --tmpfs /opt/mapr/zkdata \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v ~/Docker/logs/zk:/opt/mapr/logs \
  -v ~/Docker/ssh:/opt/mapr/conf/ssh \
  -v ~/Docker/conf:/opt/mapr/conf/replace \
  -v ~/Docker/cluster:/opt/mapr/conf/cluster \
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
  --add-host cldb-1:172.17.0.4 \
  --add-host mfs-1:172.17.0.5 \
  --add-host web-1:172.17.0.6 \
  -t "$*"
