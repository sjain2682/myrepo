#!/bin/sh

docker run -it \
    --hostname cldb-1 \
    --privileged=true \
    --security-opt seccomp=unconfined \
    --tmpfs /run --tmpfs /run/lock \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -p 7220:7220 -p 7221:7221 -p 7222:7222 \
    -v ~/Docker/logs/cldb:/opt/mapr/logs \
    -v ~/Docker/ssh:/opt/mapr/conf/ssh \
    -v ~/Docker/conf:/opt/mapr/conf/replace \
    -v ~/Docker/cluster:/opt/mapr/conf/cluster \
    --device /dev/sdf \
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
    --add-host mfs-1:172.17.0.5 \
    --add-host web-1:172.17.0.6 \
    "$*"
