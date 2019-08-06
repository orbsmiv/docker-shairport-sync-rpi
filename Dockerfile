##########################
# Building image
##########################
FROM        debian:buster-slim                                                                            AS builder

MAINTAINER  dubo-dubon-duponey@jsboot.space
# Install dependencies and tools
ARG         DEBIAN_FRONTEND="noninteractive"
ENV         TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN         apt-get update                                                                                > /dev/null
RUN         apt-get install -y git build-essential autoconf automake libtool pkg-config                   > /dev/null
WORKDIR     /build

# shairport-sync: v3.3.4
ARG         SHAIRPORT_VER=b4c54fc576bb84cbb3f4ee177bf681f60fcdea9b
# Blue-alsa: v1.4.0
ARG         BLUEZ_VERSION=2725b4e8a0301aedb267d3db5850ab62586e6148
# ALAC from apple: Feb 2019
ARG         ALAC_VERSION=5d6d836ee5b025a5e538cfa62c88bc5bced506ed


RUN         git clone git://github.com/Arkq/bluez-alsa.git
RUN         git clone git://github.com/mikebrady/alac.git
RUN         git clone git://github.com/mikebrady/shairport-sync

RUN         git -C bluez-alsa     checkout  $BLUEZ_VERSION
RUN         git -C alac           checkout  $ALAC_VERSION
RUN         git -C shairport-sync checkout  $SHAIRPORT_VER

# ALAC (from apple)
WORKDIR     /build/alac
RUN         mkdir -p m4 && autoreconf -fi && ./configure && make && make install

# blue-alsa
WORKDIR     /build/bluez-alsa
RUN         apt-get install -y check
RUN         apt-get install -y  libasound2-dev \
                        libbluetooth-dev \
                        libdbus-1-dev \
                        libglib2.0-dev \
                        libsbc-dev \
                        libreadline-dev \
                        libbsd-dev \
                        libncurses5-dev
RUN         mkdir -p m4 && autoreconf --install
RUN         mkdir build && cd build && ../configure --enable-test --enable-msbc --enable-ofono --enable-alac && make && make test && make install

# shairport-sync
WORKDIR     /build/shairport-sync
RUN         apt-get install -y  libasound2-dev \
                        libdaemon-dev \
                        libpopt-dev \
                        libsoxr-dev \
                        libavahi-client-dev \
                        libconfig-dev \
                        libssl-dev \
                        libcrypto++-dev
RUN         autoreconf -fi \
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

#######################
# Running image
#######################
FROM        debian:buster-slim

MAINTAINER  dubo-dubon-duponey@jsboot.space
ARG         DEBIAN_FRONTEND="noninteractive"
ENV         TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN         apt-get update              > /dev/null && \
            apt-get dist-upgrade -y                 && \
            apt-get install -y --no-install-recommends \
                    libbluetooth3 \
                    libsbc1 \
                    pkg-config \
                    dbus \
                    libasound2 \
                    libdaemon0 \
                    libpopt0 \
                    libsoxr0 \
                    libconfig9 \
                    libssl1.1 \
                    avahi-daemon \
                    libnss-mdns \
                    libavahi-client3 \
                    bluetooth \
                    alsa-utils          > /dev/null && \
            apt-get -y autoremove       > /dev/null && \
            apt-get -y clean            && \
            rm -rf /var/lib/apt/lists/* && \
            rm -rf /tmp/*               && \
            rm -rf /var/tmp/*

WORKDIR     /dubo-dubon-duponey
RUN         mkdir -p /var/run/dbus
COPY        avahi-daemon.conf /etc/avahi/avahi-daemon.conf
COPY        entrypoint.sh .

COPY        --from=builder /etc/shairport-sync* /etc/
COPY        --from=builder /usr/local/bin/shairport-sync /usr/local/bin/shairport-sync
COPY        --from=builder /usr/bin/bluealsa /usr/bin/bluealsa
COPY        --from=builder /usr/local/lib/libalac* /usr/local/lib/
COPY        --from=builder /usr/local/lib/pkgconfig/alac.pc /usr/local/lib/pkgconfig/alac.pc
COPY        --from=builder /usr/local/include/alac /usr/local/include/alac

# Catch-up with libalac
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH":/usr/local/lib
ENV NAME=TotaleCroquette
EXPOSE 554
#VOLUME "/etc/shairport-sync.conf"
#VOLUME "/etc/avahi/avahi-daemon.conf"

ENTRYPOINT ["./entrypoint.sh"]
