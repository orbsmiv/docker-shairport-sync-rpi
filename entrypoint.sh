#!/usr/bin/env bash

set -e

# Useful on a container restart
rm -f /var/run/dbus/pid
rm -f /run/avahi-daemon/pid

dbus-uuidgen --ensure
dbus-daemon --system
avahi-daemon --daemonize --no-chroot

exec /usr/local/bin/shairport-sync -c /etc/shairport-sync.conf -m avahi -a "$NAME" "$@"
