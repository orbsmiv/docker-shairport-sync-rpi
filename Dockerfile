FROM alpine:3.12 AS builder
MAINTAINER orbsmiv@hotmail.com

# Deliberately version agnostic - override this arg at build time
ARG SHAIRPORT_VER=x.x.x

RUN apk --no-cache -U add \
        git \
        build-base \
        autoconf \
        automake \
        libtool \
        alsa-lib-dev \
        libdaemon-dev \
        popt-dev \
        libressl-dev \
        soxr-dev \
        avahi-dev \
        libconfig-dev \
        libsndfile-dev \
        mosquitto-dev

RUN mkdir /tmp/shairport-sync \
        && git clone --recursive --depth 1 --branch ${SHAIRPORT_VER} \
        git://github.com/mikebrady/shairport-sync \
        /tmp/shairport-sync

WORKDIR /tmp/shairport-sync

RUN autoreconf -i -f \
        && ./configure \
              --with-alsa \
              --with-pipe \
              --with-avahi \
              --with-ssl=openssl \
              --with-soxr \
              --with-metadata \
              --sysconfdir=/etc \
              --without-libdaemon \
              --with-dbus-interface \
              --with-mqtt-client \
              --with-convolution \
        && make -j $(nproc) \
        && make install

FROM alpine:3.12

RUN apk add --no-cache \
        alsa-lib \
        libdaemon \
        dbus \
        popt \
        glib \
        libressl \
        soxr \
        avahi \
        libconfig \
        libsndfile \
        mosquitto-libs \
	su-exec \
      && rm -rf \
        /etc/ssl \
        /lib/apk/db/* \
        /root/shairport-sync

COPY --from=builder /etc/shairport-sync* /etc/
COPY --from=builder /etc/dbus-1/system.d/shairport-sync-dbus.conf /etc/dbus-1/system.d/
COPY --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

# Create non-root user for running the container
RUN addgroup shairport-sync && adduser -D shairport-sync -G shairport-sync

# Define the rpi's audio group (and corresponding GID) so that the running container can
# access the necessary devices
RUN addgroup -g 29 audiorpi && addgroup shairport-sync audiorpi

COPY start.sh /start.sh

ENV AIRPLAY_NAME Docker

ENTRYPOINT [ "/start.sh" ]

