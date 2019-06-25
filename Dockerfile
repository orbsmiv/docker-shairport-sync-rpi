FROM debian:stretch-slim AS builder
MAINTAINER dubo-dubon-duponey@jsboot.space

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

WORKDIR /build

RUN git clone --recursive --depth 1 --branch ${SHAIRPORT_VER} git://github.com/dubo-dubon-duponey/shairport-sync

# --with-apple-alac unsupported for now
RUN cd shairport-sync \
	&& autoreconf -i -f \
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

FROM debian:stretch-slim AS runner
MAINTAINER dubo-dubon-duponey@jsboot.space

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
        dbus \
        libasound2 \
        libdaemon0 \
        libpopt0 \
        libsoxr0 \
        libconfig9 \
        libssl1.1 \
        avahi-daemon \
        libavahi-client3 \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=builder /etc/shairport-sync* /etc/
COPY --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync

RUN mkdir -p /var/run/dbus

WORKDIR /dubo-dubon-duponey

COPY entrypoint.sh .
COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf

ENV NAME TotaleCroquette

ENTRYPOINT ["./entrypoint.sh"]
