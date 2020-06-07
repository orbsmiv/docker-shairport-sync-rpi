#!/bin/sh

set -e

su-exec shairport-sync /usr/local/bin/shairport-sync -u -c /etc/shairport-sync.conf -m tinysvcmdns -a "$AIRPLAY_NAME" "$@"
