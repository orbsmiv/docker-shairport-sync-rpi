FROM resin/armhf-alpine:latest AS builder
MAINTAINER orbsmiv@hotmail.com

RUN [ "cross-build-start" ]

ARG SHAIRPORT_VER=development

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
        libconfig-dev

RUN mkdir /root/shairport-sync \
        && git clone --recursive --depth 1 --branch ${SHAIRPORT_VER} \
        git://github.com/mikebrady/shairport-sync \
        /root/shairport-sync

WORKDIR /root/shairport-sync

RUN autoreconf -i -f \
        && ./configure \
              --with-alsa \
              --with-pipe \
              --with-avahi \
              --with-ssl=openssl \
              --with-soxr \
              --with-metadata \
              --sysconfdir=/etc \
        && make \
        && make install

RUN [ "cross-build-end" ]


FROM resin/armhf-alpine:latest

RUN [ "cross-build-start" ]

RUN apk add --no-cache \
        dbus \
        alsa-lib \
        libdaemon \
        popt \
        libressl \
        soxr \
        avahi \
        libconfig \
      && rm -rf \
        /etc/ssl \
        /lib/apk/db/* \
        /root/shairport-sync

COPY --from=builder /etc/shairport-sync* /etc/
COPY --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

COPY start.sh /start

ENV AIRPLAY_NAME Docker

ENTRYPOINT [ "/start" ]

RUN [ "cross-build-end" ]
