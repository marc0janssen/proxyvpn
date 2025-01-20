#!/bin/sh

# Name: proxyvpn
# Coder: Marco Janssen (micro.blog @marc0janssen)
# date: 2025-01-19 20:24:26
# update: 2025-01-19 20:24:26

docker image rm marc0janssen/proxyvpn:stable

docker buildx build --no-cache --platform linux/amd64,linux/arm64 --push -t marc0janssen/proxyvpn:stable -f ./Dockerfile .

docker pushrm marc0janssen/proxyvpn:stable
