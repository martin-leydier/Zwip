#!/bin/sh

if [ "$(/bin/busybox id -u)" -ne 0 ]; then
  exec $@
fi
exec /usr/bin/su-exec $UID:$GID $@
