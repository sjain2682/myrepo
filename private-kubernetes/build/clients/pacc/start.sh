#!/bin/sh

# Import our environment variables from systemd
for e in $(tr "\000" "\n" < /proc/1/environ); do
    eval "export $e"
done
echo "=== Running Startup ==="
. /opt/mapr/installer/docker/mapr-setup.sh container
echo "=== Sleeping forever to keep container up ==="
sleep infinity
