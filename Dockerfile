FROM alpine:3.9 AS alpine-builder
MAINTAINER dubodubonduponey@pm.me

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
        git://github.com/dubo-dubon-duponey/shairport-sync \
        /root/shairport-sync

WORKDIR /root/shairport-sync

# --with-apple-alac unsupported for now
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

FROM alpine:3.9 AS alpine-runner

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

COPY --from=alpine-builder /etc/shairport-sync* /etc/
COPY --from=alpine-builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

COPY start.sh /start

ENV AIRPLAY_NAME TotaleCroquette

ENTRYPOINT [ "/start" ]




FROM debian:stretch-slim AS debian-builder
MAINTAINER dubodubonduponey@pm.me

ARG SHAIRPORT_VER=development

RUN apt-get update -y && apt-get install -y \
        git \
        build-essential \
        autoconf \
        automake \
        libtool \
        libasound2-dev \
        libdaemon-dev \
        libpopt-dev \
        libsoxr-dev \
        libavahi-client-dev \
        libconfig-dev \
        libssl-dev \
        libcrypto++-dev

RUN mkdir /root/shairport-sync \
        && git clone --recursive --depth 1 --branch ${SHAIRPORT_VER} \
        git://github.com/dubo-dubon-duponey/shairport-sync \
        /root/shairport-sync

WORKDIR /root/shairport-sync

# --with-apple-alac unsupported for now
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

FROM debian:stretch-slim AS debian-runner
MAINTAINER dubodubonduponey@pm.me

RUN apt-get update -y && apt-get install -y \
        dbus \
        libasound2 \
        libdaemon0 \
        libpopt0 \
        libsoxr0 \
        libconfig9 \
        libssl1.1 \
        avahi-daemon \
        libavahi-client3 \
      && rm -rf /var/lib/apt/lists/*

COPY --from=debian-builder /etc/shairport-sync* /etc/
COPY --from=debian-builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

COPY start.sh /start

ENV AIRPLAY_NAME TotaleCroquette

ENTRYPOINT [ "/start" ]
