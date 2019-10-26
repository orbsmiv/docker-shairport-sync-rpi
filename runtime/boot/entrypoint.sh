#!/usr/bin/env bash
set -euxo pipefail

exec shairport-sync --use-stderr --mdns=tinysvcmdns --configfile=/config/shairport-sync.conf --output=alsa --name="$NAME" "$@"
