# syntax=docker/dockerfile:1.2
#
ARG UBUNTU_VERSION=20.04

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

ARG PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
ENV PATH="$PATH:/usr/lib/dart/bin:$PATH:/root/.pub-cache/bin"
WORKDIR /root/home