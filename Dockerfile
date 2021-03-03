# syntax=docker/dockerfile:1.2

# image to compile binaries
FROM google/dart:2.10.5 as dartimage
# install dependencies
RUN apt -y update && apt -y install git make gcc zip gnupg2 procps curl wget
# copy ansible project, it gets automatically copied into next image
COPY ./ /root/home/data
# create backup binary
WORKDIR /root/home/data/scripts/backup
RUN git clone https://github.com/jayjah/backder.git
RUN cd backder && git checkout master && git pull && pub get && /usr/lib/dart/bin/dart compile exe bin/main.dart -o ../backup_runtime

# ubuntu base image with backup binary
FROM ubuntu:20.04 as baseimage
LABEL maintainer="jayjah (jayjah1) <markuskrebs93@gmail.com>"
# update os && install dependencies and ansible
RUN apt -y update && apt -y upgrade && apt -y dist-upgrade
RUN apt -y install ansible python3-pip build-essential libssl-dev libffi-dev python3-dev vim sshpass hcloud-cli apache2-utils snap
RUN pip3 install hcloud passlib

# copy stuff from dart image
COPY --from=dartimage /root/home/data /root/home

WORKDIR /root/home/

