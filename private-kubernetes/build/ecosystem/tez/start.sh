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

. /opt/mapr/conf/basestart.sh
msg "=== Waiting for Spark ==="
# Add functionality
msg "=== Starting Warden ==="
service mapr-warden start
msg "=== Environment Tests ==="
msg "Container network info"
hostname
hostname -I
msg "/conf/mapr-clusters.conf"
cat /opt/mapr/conf/mapr-clusters.conf
msg "=== Sleeping forever to keep container up ==="
sleep infinity
