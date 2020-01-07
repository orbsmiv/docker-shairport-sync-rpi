#FROM resin/armhf-alpine:latest AS builder
FROM balenalib/armv7hf-alpine:3.10-build AS builder
MAINTAINER orbsmiv@hotmail.com

#RUN [ "cross-build-start" ]

ARG SHAIRPORT_VER=3.3.5

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
#              --with-dbus-interface \
              --with-mqtt-client \
              --with-convolution \
        && make -j $(nproc) \
        && make install

#RUN [ "cross-build-end" ]

FROM balenalib/armv7hf-alpine:3.10-run

#RUN [ "cross-build-start" ]

RUN apk add --no-cache \
#        dbus \
        alsa-lib \
        libdaemon \
        popt \
        libressl \
        soxr \
        avahi \
        libconfig \
        libsndfile \
        mosquitto-libs \
      && rm -rf \
        /etc/ssl \
        /lib/apk/db/* \
        /root/shairport-sync

COPY --from=builder /etc/shairport-sync* /etc/
COPY --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

COPY start.sh /start.sh

ENV AIRPLAY_NAME Docker

ENTRYPOINT [ "/start.sh" ]

#RUN [ "cross-build-end" ]
