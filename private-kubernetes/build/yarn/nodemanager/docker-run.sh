#!/bin/sh

docker run -d --hostname yarnnm-1 \
      -p 5660:5660 -p 5692:5692 -p 5724:5724 -p 5756:5756 \
      -p 8027:8027 -p 8040:8040 -p 8041:8041 -p 8042:8042 -p 8044:8044 \
      --privileged=true \
      --security-opt seccomp=unconfined \
      --tmpfs /run \
      --tmpfs /run/lock \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      -v ~/Docker/logs/yarnnm:/opt/mapr/logs \
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
      --add-host mfs-1:172.17.0.5 \
      --add-host web-1:172.17.0.6 \
      --add-host spark-1:172.17.0.7 \
      -t "$*"
