#!/bin/sh

pidof java
if [ $? -eq 0 ]; then
  exit 0
fi
exit 1
