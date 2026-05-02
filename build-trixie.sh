#!/bin/bash
# Build ghdesktop-office-web-trixie on top of ghdesktop-core-trixie.
# Distinct tag from the bookworm variant for side-by-side testing.

REGISTRY=registry.goldenhelix.com/public
DAY=$(date +'%y%m%d')

docker build \
  -t ${REGISTRY}/ghdesktop-office-web-trixie:$(arch)-${DAY} \
  -t ${REGISTRY}/ghdesktop-office-web-trixie:latest \
  --build-arg BASE_IMAGE="${REGISTRY}/ghdesktop-core-trixie" \
  --build-arg BASE_TAG="latest" \
  -f dockerfile-gh-office-web .
