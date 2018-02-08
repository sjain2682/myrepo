#!/bin/sh

ECHOE="echo -e"
NO=0
YES=1
INFO=0
WARN=-1
ERROR=1
MAPR_DB=$YES
MAPR_HOME=${MAPR_HOME:-/opt/mapr}
MEM_FILE="$MAPR_HOME/conf/container_meminfofake"
MEM_TOTAL=6291456
SECURE_CLUSTER=$NO

tput init

# Output an error, warning or regular message
msg() {
    msg_format "$1" $2
}

msg_err() {
    tput bold
    msg_format "\nERROR: $1"
    tput sgr0
    exit $ERROR
}

# Print each word according to the screen size
msg_format() {
      local length=0
      local width=$(tput cols)
      local words=$1

      width=${width:-80}
      for word in $words; do
          length=$(($length + ${#word} + 1))
          if [ $length -gt $width ]; then
              $ECHOE "\n$word \c"
              length=$((${#word} + 1))
          else
              $ECHOE "$word \c"
          fi
      done
      [ -z "$2" ] && $ECHOE "\n"
}

msg_warn() {
    tput bold
    msg_format "\nWARNING: $1"
    tput sgr0
    sleep 2
}

success() {
    local s="...Success"

    [ "$1" = "$YES" ] && s="\n$s"
    [ -n "$2" ] && s="$s - $2"
    msg "$s"
}

set_disks() {
    if [ -f "$DISKTAB_FILE" ]; then
        msg "MapR disktab file $DISKTAB_FILE already exists. Skipping disk setup"
        return
    fi
    FORCE_FORMAT=${FORCE_FORMAT:-$YES}
    DISKSETUP="$MAPR_HOME/server/disksetup"
    DISKTAB_FILE="$MAPR_HOME/conf/disktab"
    DISKLIST="/tmp/disks.txt"
    echo $MAPR_DISKS > $DISKLIST
    [ -x "$DISKSETUP" ] || msg_err "MapR disksetup utility $DISKSETUP not found"
    [ $FORCE_FORMAT -eq $YES ] && DISKARGS="$DISKARGS -F"
    msg "Setting up disk with: $DISKSETUP $DISKARGS $DISKLIST"
    $DISKSETUP $DISKARGS $DISKLIST
    if [ $? -eq 0 ]; then
        success $NO "Local disks formatted for MapR-FS"
    else
        rc=$?
        rm -f $DISKLIST $DISKTAB_FILE
        msg_err "$DISKSETUP failed with error code $rc"
    fi
    success $YES
}

create_spark_env() {
    hadoop fs -mkdir /apps/spark
    hadoop fs -chmod 777 /apps/spark
    /opt/mapr/server/configure.sh -R
}

start_slaves() {
    CONTAINER_IP=`hostname -i`
    CONTAINER_HOST=`hostname`
    SPARK_DIRECTORY="/opt/mapr/spark/spark-2.1.0/"
    sed -i -e 's/export SPARK_MASTER/#export SPARK_MASTER/' $SPARK_DIRECTORY/conf/spark-env.sh
    echo "export SPARK_MASTER_HOST=$CONTAINER_HOST" >> $SPARK_DIRECTORY/conf/spark-env.sh
    echo "export SPARK_MASTER_IP=$CONTAINER_IP" >> $SPARK_DIRECTORY/conf/spark-env.sh
    cp $SPARK_DIRECTORY/conf/slaves.template $SPARK_DIRECTORY/conf/slaves
    WORKER_LIST=$MAPR_SPARK_WORKERS
    echo "" >> $SPARK_DIRECTORY/conf/slaves
    echo -e ${WORKER_LIST//,/\\n} >> $SPARK_DIRECTORY/conf/slaves
    $SPARK_DIRECTORY/sbin/start-all.sh
}

wait_for_cldb() {
    #Make sure CLDB is up before we continue...
    COUNTER=0
    STEPCOUNTER=5
    until [  $COUNTER -gt 600 ]; do
        maprcli node list
        if [ $? -eq 0 ]; then
            COUNTER=605
        else
            sleep $STEPCOUNTER
            COUNTER=$(($COUNTER + 5))
            STEPCOUNTER=$(($STEPCOUNTER + $STEPCOUNTER))
        fi
    done
}

. /opt/mapr/conf/basestart.sh
msg "=== Waiting for CLDB ==="
wait_for_cldb
msg "=== Configuring Disks ==="
set_disks
msg "=== Creating Spark ==="
create_spark_env
msg "=== Starting Warden ==="
service mapr-warden start
msg "=== Starting Slaves ==="
start_slaves
msg "=== Environment Tests ==="
msg "Container network info"
hostname
hostname -I
msg "/conf/mapr-clusters.conf"
cat /opt/mapr/conf/mapr-clusters.conf
msg "=== Sleeping forever to keep container up ==="
sleep infinity
