# syntax=docker/dockerfile:1.2
# options:
#       [dev, prod] prod == with compiled dart libraries; dev == without compiled dart libraries
#
ARG APP_ENV=dev
ARG DART_LIBRARY_VERSION=2.12.0
ARG DART_PROD_VERSION=2.10.5
ARG UBUNTU_VERSION=latest

# :: library image ::    image to compile library binaries
FROM google/dart:$DART_LIBRARY_VERSION as libraryimage
# install dependencies
RUN apt -y update && apt -y install git make gcc zip gnupg2 procps curl wget
RUN mkdir /root/home && mkdir /root/home/data
WORKDIR /root/home
# create backup binary, will be used as cron job
RUN git clone https://github.com/jayjah/backder.git
RUN cd backder && git checkout master && git pull && pub get && /usr/lib/dart/bin/dart compile exe bin/main.dart -o /root/backup_runtime.sh

# :: prod image ::   image to compile server to binary
FROM google/dart:$DART_PROD_VERSION as prodimage
# install dependencies
RUN apt -y update && apt -y install git make gcc zip gnupg2 procps curl wget
RUN mkdir /root/home && mkdir /root/home/data
WORKDIR /root/home

# :: base image ::
FROM ubuntu:$UBUNTU_VERSION as baseimage
LABEL maintainer="jayjah (jayjah1) <markuskrebs93@gmail.com>"
# update os && install dependencies and ansible
RUN apt -y update && apt -y upgrade && apt -y dist-upgrade
RUN apt -y install ansible python3-pip build-essential libssl-dev libffi-dev python3-dev vim sshpass hcloud-cli apache2-utils snap git
RUN pip3 install hcloud passlib
RUN mkdir /root/home && mkdir /root/home/data

FROM baseimage as pre-prod-build
# set dart && pub-cache to env
COPY --from=prodimage /usr/lib/dart /usr/lib/dart
ARG PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
ENV PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
# prepare ssh
RUN mkdir -p -m 0700 /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

# :: prod build ::
FROM pre-prod-build as prod-sources
WORKDIR /
# get dart backend sources -> ssh access here needed
RUN --mount=type=ssh git clone git@gitlab.com:movementfamily/dart_backend.git && cd dart_backend && git checkout dev && git pull --recurse-submodules && git submodule update --init

FROM prod-sources as prod-build
# install aqueduct
RUN cd dart_backend/dependencies/aqueduct && pub get --no-precompile && cd ../..  && pub get --no-precompile && pub global activate --source path dependencies/aqueduct
# compile server
RUN cd dart_backend/dependencies/aqueduct && pub get && cd ../.. && pub global run aqueduct build
# bundle project
RUN tar cvzf server.tar.gz /dart_backend && cp server.tar.gz /root/server.tar.gz && chmod 0755 /root/server.tar.gz

# :: dev build ::
FROM baseimage as dev-build
RUN echo "running DEV environment! jayjah/server won't be in the final image!"

# :: final stage ::
FROM ${APP_ENV}-build as final
RUN echo "Finished Docker Build! Build environment: ${APP_ENV}"
COPY --from=libraryimage /root/backup_runtime.sh /root

WORKDIR /root/home/