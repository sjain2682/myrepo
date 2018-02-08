#!/bin/sh

docker run \
-it \
--privileged=true \
-v ~/temp:/root/temp \
"$*"
