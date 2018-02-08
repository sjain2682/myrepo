service="[.]mfs"
if ps aux | grep -q "$service"; then
  exit 1
fi
exit 0
