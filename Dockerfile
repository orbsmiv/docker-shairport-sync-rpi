FROM alpine:3.9 AS builder
MAINTAINER dubo-dubon-duponey

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

RUN autoreconf -i -f \
        && ./configure \
              --with-alsa \
              --with-pipe \
              --with-avahi \
              --with-ssl=openssl \
              --with-soxr \
              --with-metadata \
              --with-apple-alac \
              --sysconfdir=/etc \
        && make \
        && make install

FROM alpine:3.9 AS runner

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

ENV AIRPLAY_NAME TotaleCroquette

ENTRYPOINT [ "/start" ]
