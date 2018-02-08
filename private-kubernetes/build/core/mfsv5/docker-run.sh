#!/bin/sh

docker run -d --hostname mfs-1 \
      -p 5660:5660 -p 5692:5692 -p 5724:5724 -p 5756:5756 \
      --privileged=true \
      --security-opt seccomp=unconfined \
      --tmpfs /run \
      --tmpfs /run/lock \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      -v ~/Docker/logs/mfs:/opt/mapr/logs \
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
      --add-host zk-1:172.17.0.3 \
      --add-host cldb-1:172.17.0.4 \
      --add-host web-1:172.17.0.6 \
      -t "$*"
