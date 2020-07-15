#!/bin/sh

set -e

rm -rf /var/run
mkdir -p /var/run/dbus

dbus-uuidgen --ensure
dbus-daemon --system

avahi-daemon --daemonize --no-chroot

su-exec shairport-sync /usr/local/bin/shairport-sync -u -c /etc/shairport-sync.conf -m avahi -a "${AIRPLAY_NAME}" "${@}"
