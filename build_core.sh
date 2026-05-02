#!/bin/bash
# Build ghdesktop-office-web-noble (Ubuntu 24.04) on top of the noble
# ghdesktop-core-noble image. Distinct tag from the bookworm-based
# ghdesktop-office-web in appstream-images for side-by-side testing.

REGISTRY=registry.goldenhelix.com/public
DAY=$(date +'%y%m%d')

docker build \
  -t ${REGISTRY}/ghdesktop-office-web-noble:$(arch)-${DAY} \
  -t ${REGISTRY}/ghdesktop-office-web-noble:latest \
  --build-arg BASE_TAG="latest" \
  -f dockerfile-gh-office-web .
