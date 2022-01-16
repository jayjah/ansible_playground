# syntax=docker/dockerfile:1.2
#
ARG APP_ENV=dev
ARG DART_VERSION=stable
ARG UBUNTU_VERSION=latest

# :: dart image::
FROM dart:$DART_VERSION as dartimage
RUN apt-get -y update && apt-get -y install git make gcc gnupg2 procps curl wget && mkdir /root/home && mkdir /root/home/data
WORKDIR /root/home

# :: library image ::
FROM dartimage as libraryimage
RUN git clone https://github.com/jayjah/backder.git && cd backder && git checkout master && git pull && dart pub get && dart compile exe bin/main.dart -o /root/backup_runtime.sh
WORKDIR /root/home

# :: prod image ::
FROM dartimage as prodimage
WORKDIR /root/home

# :: base image ::
FROM ubuntu:$UBUNTU_VERSION as baseimage
# update os && install dependencies, ansible, restic, etc
RUN apt-get -y update && apt -y upgrade && apt -y dist-upgrade && apt-get -y install ansible python3-pip build-essential libssl-dev libffi-dev python3-dev vim sshpass hcloud-cli apache2-utils snap git zip unzip restic && pip3 install --no-cache-dir hcloud passlib && mkdir /root/home && mkdir /root/home/data

FROM baseimage as pre-prod-build
COPY --from=prodimage /usr/lib/dart /usr/lib/dart
ARG PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
ENV PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
# just prepare ssh access
RUN mkdir -p -m 0700 /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

# :: prod build ::
FROM pre-prod-build as prod-build
WORKDIR /
# get server sources -> ssh access needed here
RUN mkdir dependencies \
    && git clone https://github.com/jayjah/aqueduct.git dependencies/ \
    && cd dependencies \
    && git checkout override_with_git \
    && git pull \
    && dart pub get \
    && dart pub global activate --source path .

# :: dev build ::
FROM baseimage as dev-build
RUN echo "running DEV environment!"

# :: final stage ::
FROM ${APP_ENV}-build as final
LABEL maintainer="jayjah (jayjah1) <markuskrebs93@gmail.com>"
RUN echo "Finished Docker Build! Build environment: ${APP_ENV}"
COPY --from=libraryimage /root/backup_runtime.sh /root
WORKDIR /root/home/