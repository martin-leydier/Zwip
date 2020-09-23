#!/bin/sh

if [ -z "$UID" ] || [ -z "$GID" ]; then
  echo "Invalid UID('$UID') or GID('$GID')"
  exit 1
fi

if [ -n "$RUN_AS_CURRENT_USER" ] && [ "$(/bin/id -u)" -ne 0 ]; then
  exec $@
fi

exec /usr/bin/su-exec "$UID:$GID" $@
