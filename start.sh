#!/bin/sh

set -e

rm -rf /var/run
mkdir -p /var/run/dbus

dbus-uuidgen --ensure
dbus-daemon --system

avahi-daemon --daemonize --no-chroot

exec /usr/local/bin/shairport-sync -c /etc/shairport-sync.conf -m avahi -a "$AIRPLAY_NAME" "$@"
