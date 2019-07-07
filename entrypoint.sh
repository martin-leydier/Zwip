#!/bin/sh

/bin/busybox rm -rf /bin
exec /sbin/su-exec $UID:$GID $@
