#!/usr/bin/env bash

set -e

dbus-uuidgen --ensure
dbus-daemon --system
avahi-daemon --daemonize --no-chroot

exec /usr/local/bin/shairport-sync -c /etc/shairport-sync.conf -m avahi -a "$NAME" "$@"
