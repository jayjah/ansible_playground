# syntax=docker/dockerfile:1.2
# options: [dev, prod]
ARG APP_ENV=dev

FROM scratch as data
COPY ./ /root/home/data

# image to compile binaries
FROM google/dart:2.10.5 as dartimage
# install dependencies
RUN apt -y update && apt -y install git make gcc zip gnupg2 procps curl wget
RUN mkdir /root/home && mkdir /root/home/data
WORKDIR /root/home
# create backup binary, will be used as cron job
RUN git clone https://github.com/jayjah/backder.git
RUN cd backder && git checkout master && git pull && pub get && /usr/lib/dart/bin/dart compile exe bin/main.dart -o /root/home/data/backup_runtime.sh

# ubuntu base image with backup binary
FROM ubuntu:20.04 as baseimage
LABEL maintainer="jayjah (jayjah1) <markuskrebs93@gmail.com>"
# update os && install dependencies and ansible
RUN apt -y update && apt -y upgrade && apt -y dist-upgrade
RUN apt -y install ansible python3-pip build-essential libssl-dev libffi-dev python3-dev vim sshpass hcloud-cli apache2-utils snap git
RUN pip3 install hcloud passlib
RUN mkdir /root/home && mkdir /root/home/data

FROM baseimage as pre-prod-build
# set dart && pub-cache to env
COPY --from=dartimage /usr/lib/dart /usr/lib/dart
ARG PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
ENV PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
# prepare ssh
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts && ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

FROM pre-prod-build as prod-sources
WORKDIR /
# get aqueduct
RUN git clone https://github.com/jayjah/aqueduct.git
# get dart backend sources -> ssh access here needed
RUN --mount=type=ssh git clone git@gitlab.com:movementfamily/dart_backend.git && cd dart_backend && git checkout dev && git pull --recurse-submodules && git submodule update --init

# production build :: includes jayjah/server in the final image
FROM prod-sources as prod-build
# install aqueduct
RUN cd aqueduct && git checkout override_with_git && git pull && pub get && pub global activate --source path .
# compile jayjah/server
RUN cd dart_backend && /usr/lib/dart/bin/pub get --no-precompile && /usr/lib/dart/bin/pub global run aqueduct build && cp /dart_backend/dart_backend.aot /root/home
# copy stuff from other images
COPY --from=data /root/home/data /root/home/

# dev build ::
FROM baseimage as dev-build
RUN echo "running DEV environment! jayjah/server won't be in the final image!"

# :: final ::
FROM ${APP_ENV}-build as final
RUN echo "Finished Docker Build! Build environment: ${APP_ENV}"
WORKDIR /root/home/
