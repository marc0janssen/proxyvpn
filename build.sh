#!/bin/sh

# Name: docker-nzbgetvpn
# Coder: Marco Janssen (twitter @marc0janssen)
# date: 2021-11-28 14:24:26
# update: 2021-11-28 14:24:32

docker image rm marc0janssen/proxyvpn:stable

docker buildx build --no-cache --platform linux/amd64,linux/arm64 --push -t marc0janssen/proxyvpn:stable -f ./Dockerfile .

docker pushrm marc0janssen/proxyvpn:stable
