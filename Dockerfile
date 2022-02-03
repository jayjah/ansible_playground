# syntax=docker/dockerfile:1.2
#
ARG DART_VERSION=2.15.1
ARG UBUNTU_VERSION=20.04

# :: dart image::
FROM dart:$DART_VERSION as library
LABEL maintainer="jayjah (jayjah1) <markuskrebs93@gmail.com>"
# create library
RUN apt-get -y install git \
    && git clone https://github.com/jayjah/backder.git \
    && cd backder \
    && git checkout master \
    && dart pub get \
    && dart compile exe bin/main.dart -o /root/backup_runtime.sh

# :: base image ::
FROM ubuntu:$UBUNTU_VERSION as baseimage
# update os && install dependencies, ansible, restic, etc
RUN apt-get -y update \
    && apt -y upgrade \
    && apt -y dist-upgrade \
    && apt-get -y install ansible python3-pip build-essential libssl-dev libffi-dev python3-dev vim sshpass hcloud-cli apache2-utils snap git zip unzip restic make \
    && pip3 install --no-cache-dir hcloud passlib \
    && mkdir /root/home \
    && mkdir /root/home/data
# install dart and dart conduit server framework
COPY --from=library /usr/lib/dart /usr/lib/dart
COPY --from=library /root/backup_runtime.sh /root
ARG PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
ENV PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
RUN dart pub global activate conduit
WORKDIR /root/home