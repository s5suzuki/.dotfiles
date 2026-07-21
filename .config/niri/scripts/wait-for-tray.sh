#!/bin/sh

set -eu

BUS_NAME="org.kde.StatusNotifierWatcher"
TIMEOUT="${WAIT_FOR_TRAY_TIMEOUT:-30}"

if command -v gdbus > /dev/null 2>&1; then
  gdbus wait --session --timeout "$TIMEOUT" "$BUS_NAME" || true
else
  i=0
  while [ "$i" -lt "$TIMEOUT" ]; do
    if busctl --user list 2> /dev/null | grep -q "$BUS_NAME"; then
      break
    fi
    sleep 1
    i=$((i + 1))
  done
fi

sleep 1

exec "$@"
