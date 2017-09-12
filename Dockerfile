FROM hypriot/rpi-alpine:latest
MAINTAINER orbsmiv@hotmail.com

RUN apk -U add \
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
        curl

RUN mkdir /root/shairport-sync
WORKDIR /root/shairport-sync

RUN curl -L -o ./shairport-sync.tar.gz https://github.com/mikebrady/shairport-sync/archive/3.1.2.tar.gz
RUN tar -zxvf shairport-sync.tar.gz --strip-components=1
RUN rm shairport-sync.tar.gz


RUN autoreconf -i -f \
 && ./configure \
        --with-alsa \
        --with-pipe \
        --with-avahi \
        --with-ssl=openssl \
        --with-soxr \
        --with-metadata \
 && make \
 && make install

WORKDIR /

RUN apk --purge del \
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
 && apk add \
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
        /var/cache/apk/* \
        /lib/apk/db/* \
        /root/shairport-sync

COPY start.sh /start

ENV AIRPLAY_NAME Docker

ENTRYPOINT [ "/start" ]
