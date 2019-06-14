# What

Based on [shairport-sync](https://github.com/mikebrady/shairport-sync), an Apple AirPlay receiver.

It can receive audio directly from iOS devices, iTunes, etc. Multiple instances of shairport-sync will stay in sync with each other and other AirPlay devices when used with a compatible multi-room player, such as iTunes, Roon, or [forked-daapd](https://github.com/jasonmc/forked-daapd).

This here is yet another fork of kevineye original docker image.

The main difference here is that it is base on vanilla alpine (3.9), and generates a multi-architecture image (amd64, arm64, amrv7, armv6).

Currently running this on a raspberry pi (armhf).

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
