#!/bin/bash
# Build ghdesktop-office-web on the trixie core.
#
# Tags BOTH:
#   ghdesktop-office-web-trixie:latest   ← variant-specific
#   ghdesktop-office-web:latest          ← unsuffixed default (what
#                                          Dockerfile.varseq's default
#                                          BASE_IMAGE points at).
#
# Trixie is the only variant we actively maintain — the unsuffixed tag
# IS the trixie build.

REGISTRY=registry.goldenhelix.com/public
DAY=$(date +'%y%m%d')

docker build \
  -t ${REGISTRY}/ghdesktop-office-web-trixie:$(arch)-${DAY} \
  -t ${REGISTRY}/ghdesktop-office-web-trixie:latest \
  -t ${REGISTRY}/ghdesktop-office-web:latest \
  --build-arg BASE_IMAGE="${REGISTRY}/ghdesktop-core-trixie" \
  --build-arg BASE_TAG="latest" \
  -f dockerfile-gh-office-web .
