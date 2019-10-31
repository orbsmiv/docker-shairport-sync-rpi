#######################
# Building image
#######################
FROM          dubodubonduponey/base:builder                                   AS builder

WORKDIR       /build

# shairport-sync: v3.3.2
ARG           SHAIRPORT_VER=ca9b2ff3bc1630c9de95f4555d4398d1a33ec2a3
# with sigsegv fixes
ARG           SHAIRPORT_VER=0e85ec370a08c3443b0b9e28707d1022efc0f74f
# ALAC from apple: Feb 2019
ARG           ALAC_VERSION=5d6d836ee5b025a5e538cfa62c88bc5bced506ed

RUN           git clone git://github.com/mikebrady/alac.git
RUN           git clone git://github.com/mikebrady/shairport-sync
RUN           git -C alac           checkout $ALAC_VERSION
RUN           git -C shairport-sync checkout $SHAIRPORT_VER

RUN           apt-get install -y --no-install-recommends \
                libasound2-dev=1.1.8-1 \
                libpopt-dev=1.16-12 \
                libsoxr-dev=0.1.2-3 \
                libconfig-dev=1.5-0.4 \
                libssl-dev=1.1.1d-0+deb10u2 \
                libcrypto++-dev=5.6.4-8                                       > /dev/null

# ALAC (from apple)
WORKDIR       /build/alac
RUN           mkdir -p m4 \
                && autoreconf -fi \
                && ./configure \
                && make \
                && make install

# shairport-sync
WORKDIR       /build/shairport-sync
# Do we really want libsoxr
RUN           autoreconf -fi \
                && ./configure \
                  --with-alsa \
                  --with-tinysvcmdns \
                  --with-ssl=openssl \
                  --with-soxr \
                  --with-piddir=/data/pid \
                  --with-apple-alac \
                  --sysconfdir=/config \
                && make \
                && make install

#######################
# Extra builder for golang healthchecker
#######################
FROM          --platform=$BUILDPLATFORM dubodubonduponey/base:builder         AS healthcheck-builder

# XXX not cool - move that code into a proper separate repo (along with http-client)
WORKDIR       $GOPATH/src/github.com/dubo-dubon-duponey/healthchecker
COPY          rtsp-client.go cmd/rtsp-client/rtsp-client.go
RUN           arch="${TARGETPLATFORM#*/}"; \
              env GOOS=linux GOARCH="${arch%/*}" go build -v -ldflags "-s -w" -o /dist/bin/rtsp-client ./cmd/rtsp-client

RUN           chmod 555 /dist/bin/*

#######################
# Running image
#######################
FROM          dubodubonduponey/base:runtime

USER          root

ARG           DEBIAN_FRONTEND="noninteractive"
ENV           TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN           apt-get update                > /dev/null \
              && apt-get install -y --no-install-recommends \
                libasound2=1.1.8-1 \
                libpopt0=1.16-12 \
                libsoxr0=0.1.2-3 \
                libconfig9=1.5-0.4 \
                libssl1.1=1.1.1c-1          > /dev/null \
              && apt-get -y autoremove      > /dev/null \
              && apt-get -y clean            \
              && rm -rf /var/lib/apt/lists/* \
              && rm -rf /tmp/*               \
              && rm -rf /var/tmp/*

USER          dubo-dubon-duponey

COPY          --from=builder /usr/local/bin/shairport-sync /boot/bin/shairport-sync
COPY          --from=builder /usr/local/lib/libalac.so.0 /boot/lib/
COPY          --from=healthcheck-builder /dist/bin/rtsp-client /boot/bin/

# Catch-up with libalac
ENV           LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/boot/lib"
ENV           NAME=TotaleCroquette
ENV           HEALTHCHECK_URL=rtsp://127.0.0.1:5000
ENV           PATH=/boot/bin:$PATH

EXPOSE        5000/tcp
EXPOSE        6001-6011/udp

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=1 CMD rtsp-client || exit 1
