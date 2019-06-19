# What

Docker image (amd64, arm64, armv7, armv6) for [shairport-sync](https://github.com/mikebrady/shairport-sync), an Apple AirPlay receiver.

This is based on Debian, unlike most of the other images around.

The reason is simple: avahi segfaults on Alpine - regularly.

## Run

```
docker run -d \
    --net host \
    --device /dev/snd \
    -e AIRPLAY_NAME=TotaleCroquette \
    dubodubonduponey/audio-shairport-sync:v1
```

You may optionally pass along `-v /path/to/custom/shairport-sync.conf:/etc/shairport-sync.conf`,
or additional arguments, that will get stuffed into the shairport binary.

## Notes

Both an Alpine and a Debian version are defined in the Dockerfile.

Debian is the default, for reasons outlined above.

Differences compared to `kevineye` image:

 * based on debian or vanilla alpine (3.9) instead of resin / balena
 * generates a multi-architecture image (amd64, arm64, amrv7, armv6)
 * shairport-sync source is forked under `dubo-dubon-duponey`
 * tested daily for many hours in production (sitting at my desk) on a raspberry armv7 (using the Debian variant)
