# What

Docker image (amd64, arm64, armv7, armv6) for [shairport-sync](https://github.com/mikebrady/shairport-sync), an Apple AirPlay receiver.

It can receive audio directly from iOS devices, iTunes, etc. Multiple instances of shairport-sync will stay in sync with each other and other AirPlay devices when used with a compatible multi-room player, such as iTunes, Roon, or [forked-daapd](https://github.com/jasonmc/forked-daapd).

This is yet another fork of kevineye original docker image.

## Run

```
docker run -d \
    --net host \
    --device /dev/snd \
    -e AIRPLAY_NAME=TotaleCroquette \
    -v /path/to/custom/shairport-sync.conf:/etc/shairport-sync.conf
    dubodubonduponey/audio-airport:v1
```

### Parameters

 * `--net host` is mandatory for this to work
 * `--device /dev/snd` is mandatory as well
 * `-e AIRPLAY_NAME=TotaleCroquette` set the AirPlay device name. Defaults to TotaleCroquette
 * extra arguments will be passed to shairplay-sync (try `-- help`)

## Notes

Differences compared to kevineye image:

 * based on vanilla alpine (3.9) instead of resin / balena
 * generates a multi-architecture image (amd64, arm64, amrv7, armv6)
 * shairport-sync source is forked under `dubo-dubon-duponey`
 * tested daily in production on a raspberry armv7 :p
