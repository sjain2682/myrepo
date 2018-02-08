#!/bin/sh

ECHOE="echo -e"

NO=0
YES=1
INFO=0
WARN=-1
ERROR=1

OPENJDK_DEB=${OPENJDK_DEB:-openjdk-7-jdk}
OPENJDK_DEB_7=${OPENJDK_DEB_7:-openjdk-7-jdk}
OPENJDK_DEB_8=${OPENJDK_DEB_8:-openjdk-8-jdk}
OPENJDK_RPM=${OPENJDK_RPM:-java-1.8.0-openjdk-devel}
OPENJDK_RPM_7=${OPENJDK_RPM_7:-java-1.7.0-openjdk-devel}
OPENJDK_RPM_8=${OPENJDK_RPM_8:-java-1.8.0-openjdk-devel}
OPENJDK_SUSE=${OPENJDK_SUSE:-java-1_8_0-openjdk-devel}
OPENJDK_SUSE_7=${OPENJDK_SUSE_7:-java-1_7_0-openjdk-devel}
OPENJDK_SUSE_8=${OPENJDK_SUSE_8:-java-1_8_0-openjdk-devel}
OPENJDK_DEB_HL=${OPENJDK_DEB_HL:-openjdk-7-jre-headless}
OPENJDK_DEB_7_HL=${OPENJDK_DEB_7_HL:-openjdk-7-jre-headless}
OPENJDK_DEB_8_HL=${OPENJDK_DEB_8_HL:-openjdk-8-jre-headless}
OPENJDK_RPM_HL=${OPENJDK_RPM_HL:-java-1.8.0-openjdk-headless}
OPENJDK_RPM_7_HL=${OPENJDK_RPM_7_HL:-java-1.7.0-openjdk-headless}
OPENJDK_RPM_8_HL=${OPENJDK_RPM_8_HL:-java-1.8.0-openjdk-headless}
OPENJDK_SUSE_HL=${OPENJDK_SUSE_HL:-java-1_8_0-openjdk-headless}
OPENJDK_SUSE_7_HL=${OPENJDK_SUSE_7_HL:-java-1_7_0-openjdk-headless}
OPENJDK_SUSE_8_HL=${OPENJDK_SUSE_8_HL:-java-1_8_0-openjdk-headless}
MAPR_DB=$YES
MAPR_HOME=${MAPR_HOME:-/opt/mapr}
MEM_FILE="$MAPR_HOME/conf/container_meminfofake"
MEM_TOTAL=6291456
SECURE_CLUSTER=$NO

export JDK_QUIET_CHECK=$YES # don't want env.sh to exit
export JDK_REQUIRED=$YES    # ensure we have full JDK
export TERM=${TERM:-ansi}

JAVA_HOME_OLD=
JDK_UPDATE_ONLY=$NO
JDK_UPGRADE_JRE=$NO
JDK_VER=0

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


check_jdk() {
      # if javac exists, then JDK-devel has been installed
      msg "Testing for JDK 7 or higher..."
      [ -n "$JAVA_HOME" ] && JAVA_HOME_OLD=$JAVA_HOME

      # determine what kind of Java env we have
      check_java_env
      if [ -z "$JAVA_HOME" ]; then
          # try again to see if we have a valid JRE
          JDK_REQUIRED=0
          check_java_env
          if [ -n "$JAVA_HOME" ]; then
              JAVA=$JAVA_HOME/bin/java
              JDK_UPGRADE_JRE=1
          fi
      else
          JAVA=$JAVA_HOME/bin/java
      fi
      if [ -n "$JAVA" -a -e "$JAVA" ]; then
          JDK_VER=$($JAVA_HOME/bin/java -version 2>&1 | head -n1 | cut -d. -f2)
      fi

      # check if javac is actually valid and exists
      local msg

      if [ -n "$JAVA_HOME" -a $JDK_UPGRADE_JRE -eq $YES ]; then
          msg="Upgrading JRE to JDK 1.$JDK_VER"
          force_jdk_version $JDK_VER
      elif [ -z "$JAVA_HOME" ]; then
          if [ "$OS" == "ubuntu" -a $OSVER_MAJ -ge 16 ]; then
              force_jdk_version 8
          fi
          msg="JDK not found - installing $OPENJDK..."
      else
          msg="Ensuring existing JDK 1.$JDK_VER is up to date..."
      fi
      success
      export JAVA_HOME
      msg "JAVA_HOME is $JAVA_HOME"
}

# WARNING:  You must replicate any changes here in env.sh
check_java_env() {
    # We use this flag to force checks for full JDK
    JDK_QUIET_CHECK=${JDK_QUIET_CHECK:-0}
    JDK_REQUIRED=${JDK_REQUIRED:-0}
    # Handle special case of bogus setting in some virtual machines
    [ "${JAVA_HOME:-}" = "/usr" ] && JAVA_HOME=""

    # Look for installed JDK
    if [ -z "$JAVA_HOME" ]; then
        sys_java="/usr/bin/java"
        if [ -e $sys_java ]; then
            jcmd=$(readlink -f $sys_java)
            if [ $JDK_REQUIRED -eq 1 ]; then
                if [ -x ${jcmd%/jre/bin/java}/bin/javac ]; then
                    JAVA_HOME=${jcmd%/jre/bin/java}
                elif [ -x ${jcmd%/java}/javac ]; then
                    JAVA_HOME=${jcmd%/bin/java}
                fi
            else
                if [ -x ${jcmd} ]; then
                    JAVA_HOME=${jcmd%/bin/java}
                fi
            fi
            [ -n "$JAVA_HOME" ] && export JAVA_HOME
        fi
    fi

    check_java_home
    # MARKER - DO NOT DELETE THIS LINE
    # attempt to find java if JAVA_HOME not set
    if [ -z "$JAVA_HOME" ]; then
        for candidate in \
            /Library/Java/Home \
            /usr/java/default \
            /usr/lib/jvm/default-java \
            /usr/lib*/jvm/java-8-openjdk* \
            /usr/lib*/jvm/java-8-oracle* \
            /usr/lib*/jvm/java-8-sun* \
            /usr/lib*/jvm/java-1.8.* \
            /usr/lib*/jvm/java-1.8.*/jre \
            /usr/lib*/jvm/java-7-openjdk* \
            /usr/lib*/jvm/java-7-oracle* \
            /usr/lib*/jvm/java-7-sun* \
            /usr/lib*/jvm/java-1.7.*/jre \
            /usr/lib*/jvm/java-1.7.* ; do
            if [ -e $candidate/bin/java ]; then
                export JAVA_HOME=$candidate
                check_java_home
                if [ -n "$JAVA_HOME" ]; then
                    break
                fi
            fi
        done
        # if we didn't set it
        if [ -z "$JAVA_HOME" -a $JDK_QUIET_CHECK -eq $NO ]; then
            cat 1>&2 <<EOF
+======================================================================+
|      Error: JAVA_HOME is not set and Java could not be found         |
+----------------------------------------------------------------------+
| MapR requires Java 1.7 or later.                                     |
| NOTE: This script will find Oracle or Open JDK Java whether you      |
|       install using the binary or the RPM based installer.           |
+======================================================================+
EOF
            exit 1
        fi
    fi

    if [ -n "${JAVA_HOME}" ]; then
        # export JAVA_HOME to PATH
        export PATH=$JAVA_HOME/bin:$PATH
    fi
}

# WARNING: The code from here to the next tag is included in env.sh.
#          any changes should be applied there too
check_java_home() {
    local found=0
    if [ -n "$JAVA_HOME" ]; then
        if [ $JDK_REQUIRED -eq 1 ]; then
            if [ -e "$JAVA_HOME"/bin/javac -a -e "$JAVA_HOME"/bin/java ]; then
                found=1
            fi
        elif [ -e "$JAVA_HOME"/bin/java ]; then
            found=1
        fi
        if [ $found -eq 1 ]; then
            java_version=$($JAVA_HOME/bin/java -version 2>&1 | fgrep version | \
                head -n1 | cut -d '.' -f 2)
            [ -z "$java_version" ] || echo $java_version | \
                fgrep -i Error > /dev/null 2>&1 || [ "$java_version" -le 6 ] && \
                unset JAVA_HOME
        else
            unset JAVA_HOME
        fi
    fi
}

# Set full JDK version corresponding to current JRE
force_jdk_version() {
    local pkg

    case $OS in
    redhat) pkg="OPENJDK_RPM_$1" ;;
    suse) pkg="OPENJDK_SUSE_$1" ;;
    ubuntu) pkg="OPENJDK_DEB_$1" ;;
    esac
    OPENJDK=${!pkg}
}

run_config() {
  ARGS="-no-autostart -on-prompt-cont y -v"
  CONTAINER_CONFIGURE_SCRIPT="$MAPR_HOME/server/configure.sh"
  DISKLIST="$MAPR_HOME/conf/disks.txt"
  if [ -x $CONTAINER_CONFIGURE_SCRIPT ]; then
      if [ $MAPR_DB != "true" ]; then
          ARGS="$ARGS -noDB"
      fi
      echo "SECURE_CLUSTER=$SECURE_CLUSTER"
      if [ $SECURE_CLUSTER -eq $YES ]; then
          ARGS="$ARGS -secure"
      else
          msg_warn "Creating an unsecure cluster"
      fi
      ARGS="$ARGS $MAPR_SECURITY -N $MAPR_CLUSTER -C $MAPR_CLDB_HOSTS -Z $MAPR_ZK_HOSTS"
      container_command="$CONTAINER_CONFIGURE_SCRIPT $ARGS"
      msg "Calling $container_command..."
      $container_command
  else
      msg "$CONTAINER_CONFIGURE_SCRIPT is not executable..."
  fi
  success $YES
}

set_environment() {
    # Import our environment variables from systemd
    for e in $(tr "\000" "\n" < /proc/1/environ); do
        eval "export $e"
    done
    # Copy SSH certs to container
    if [ -d $MAPR_HOME/conf/ssh ]; then
        mkdir ~/.ssh
        cp $MAPR_HOME/conf/ssh/authorized_keys ~/.ssh/authorized_keys
        cp $MAPR_HOME/conf/ssh/* ~/.ssh/
        chmod 700 ~/.ssh
        chmod 644 ~/.ssh/id_rsa.pub
        chmod 644 ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/id_rsa
    else
         msg_warn "SSH volume not connected"
    fi
    # Copy modified conf files to container
    if [ -d $MAPR_HOME/conf/replace ]; then
        cp $MAPR_HOME/conf/replace/* $MAPR_HOME/conf/
    else
         msg_warn "Conf file replacement volume not connected"
    fi
    # Copy secure cluster files to conatiner
    if [ -d $MAPR_HOME/conf/cluster ]; then
        SECURE_CLUSTER=$YES
        cp $MAPR_HOME/conf/cluster/* $MAPR_HOME/conf/
    else
        msg_warn "Secure cluster volume not connected"
        SECURE_CLUSTER=$NO
    fi
    printenv
    msg "MAPR_USER is $MAPR_USER"
    success $YES
}

set_hostname() {
    # Ensure we have hostnames set properly for container
    cat /etc/hosts
    rm -f $MAPR_HOME/hostid
    rm -f $MAPR_HOME/hostname
    msg "Creating hostid file"
    $MAPR_HOME/server/mruuidgen > $MAPR_HOME/hostid
    cp $MAPR_HOME/hostid $MAPR_HOME/conf/hostid.$$
    chmod 444 $MAPR_HOME/hostid
    msg "Creating hostname file"
    hostname -f > $MAPR_HOME/hostname
    chmod 444 $MAPR_HOME/hostname
    success $YES
}

set_memory() {
    # Set fake memory available since we are running in a container
    msg "MAPR_MEMORY = $MAPR_MEMORY"
    cp -f -v /proc/meminfo $MEM_FILE
    sed -i "s!/proc/meminfo!${MEM_FILE}!" "$MAPR_HOME/server/initscripts-common.sh" || \
        msg_err "Could not edit initscripts-common.sh"
    sed -i "/^MemTotal/ s/^.*$/MemTotal:     ${MEM_TOTAL} kB/" "$MEM_FILE" || \
        msg_err "Could not edit meminfo MemTotal"
    sed -i "/^MemFree/ s/^.*$/MemFree:     ${MEM_TOTAL-10} kB/" "$MEM_FILE" || \
        msg_err "Could not edit meminfo MemFree"
    sed -i "/^MemAvailable/ s/^.*$/MemAvailable:     ${MEM_TOTALL-10} kB/" "$MEM_FILE" || \
        msg_err "Could not edit meminfo MemAvailable"
    success $YES
}

set_timezone() {
    local file="/usr/share/zoneinfo/$MAPR_TZ"
    #[ ! -f $file ] && msg_err "Invalid MAPR_TZ timezone ($MAPR_TZ)"
    ln -f -s "$file" /etc/localtime
    success $YES
}

set_user() {
    if getent group $MAPR_GID > /dev/null 2>&1 ; then
        msg_warn "$MAPR_GROUP already exists..."
    else
        # create the new group with the given group id
        msg "Creating Group: $MAPR_GROUP ID: $MAPR_GID"
        RESULTS=$(groupadd -g $MAPR_GID $MAPR_GROUP 2>&1)
        if [ $? -ne 0 ]; then
            msg_err "Unable to create group $MAPR_GROUP: $RESULTS"
        fi
    fi
    if getent passwd $MAPR_UID > /dev/null 2>&1 ; then
        msg_warn "uid $MAPR_UID already exists"
        useradd -G $MAPR_GROUP $MAPR_USER
    else
        # create the new group with the given group id
        msg "Creating User: $MAPR_USER UID: $MAPR_UID GID: $MAPR_GID"
        RESULTS=$(useradd -m -u $MAPR_UID -g $MAPR_GID -G $(stat -c '%G' /etc/shadow) $MAPR_USER)
    fi
    $MAPR_HOME/server/config-mapr-user.sh -u $MAPR_USER
    echo "root:$MAPR_ROOT_PASSWORD" | chpasswd
    echo "$MAPR_USER:$MAPR_PASSWORD" | chpasswd
    success $YES
}

msg "=== Set Hostname ==="
set_hostname
msg "=== Checking JDK ==="
check_jdk
msg "=== Set ENV ==="
set_environment
msg "=== Configuring Timezone ==="
set_timezone
msg "=== Configuring User ==="
set_user
msg "=== Configuring Memory ==="
set_memory
msg "=== Running CONFIG.SH ==="
run_config
