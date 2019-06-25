# What

Docker image (amd64, arm64, armv7, armv6) for [shairport-sync](https://github.com/mikebrady/shairport-sync), an Apple AirPlay receiver.

This is based on Debian, unlike most of the other images around. The reason is simple: avahi segfaults on Alpine regularly.

## Run

```bash
docker run -d \
    --net host \
    --device /dev/snd \
    -e NAME=TotaleCroquette \
    dubodubonduponey/shairport-sync:v1
```

## Notes

### Network

 * `bridge` mode will NOT work, since mDNS will not broadcast on your lan subnet
 * `host` (default, easy choice) is only acceptable as long as you DO NOT have any other containers running on the same host using avahi

If you intend on running multiple containers relying on avahi (like a timemachine server for eg), or even two instances
of `shairport-sync`, you may want to consider `macvlan`.

TL;DR:

```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --ip-range=192.168.1.128/25 \
  --gateway=192.168.1.1 \
  -o parent=eth0 hackvlan
  
docker run -d -e NAME=N1 --device=/dev/snd --name=N1 --network=hackvlan dubodubonduponey/shairport-sync:v1
docker run -d -e NAME=N2 --device=/dev/snd --name=N2 --network=hackvlan dubodubonduponey/shairport-sync:v1
```

Need help with macvlan?
[Hit yourself up](https://docs.docker.com/network/macvlan/).

### Advanced configuration

Would you need to, you may optionally pass along:
 
 * `-v /path/to/custom/shairport-sync.conf:/etc/shairport-sync.conf` if you want to tweak shairport configuration
 * `-v /path/to/custom/avahi-daemon.conf:/etc/avahi/avahi-daemon.conf` if you need to tweak avahi

Also, any additional arguments when running the image will get fed to the shairport binary.

### Base OS

I gave up on alpine. git history for posterity.

Main differences compared to `kevineye` image:

 * based on debian or vanilla alpine (3.9) instead of resin / balena
 * generates a multi-architecture image (amd64, arm64, amrv7, armv6)
 * shairport-sync source is forked on github under `dubo-dubon-duponey`
 * tested daily for many hours in production (sitting at my desk) on a raspberry armv7
