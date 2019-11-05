#!/bin/sh

if [ "$(/bin/busybox id -u)" -ne 0 ]; then
  exec $@
fi
exec /sbin/su-exec $UID:$GID $@
