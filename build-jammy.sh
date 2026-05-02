#!/bin/bash
# Build ghdesktop-office-web-jammy on top of ghdesktop-core-jammy.
# Distinct tag from the noble variant for side-by-side testing.

REGISTRY=registry.goldenhelix.com/public
DAY=$(date +'%y%m%d')

docker build \
  -t ${REGISTRY}/ghdesktop-office-web-jammy:$(arch)-${DAY} \
  -t ${REGISTRY}/ghdesktop-office-web-jammy:latest \
  --build-arg BASE_IMAGE="${REGISTRY}/ghdesktop-core-jammy" \
  --build-arg BASE_TAG="latest" \
  -f dockerfile-gh-office-web .
