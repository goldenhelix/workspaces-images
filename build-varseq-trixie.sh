#!/bin/bash
# Build ghdesktop-varseq-trixie (VarSeq DEV5 baked in, debian 13).
#
# Base: ghdesktop-office-web:$OFFICE_WEB_TAG (dated, NOT :latest).
# OFFICE_WEB_TAG is read from ./LAST_BUILD.tag by default (written by
# build-trixie.sh); override via env var:
#   OFFICE_WEB_TAG=260518 ./build-varseq-trixie.sh

set -euo pipefail

REGISTRY=registry.goldenhelix.com/public
DAY=$(date +'%y%m%d')
VS_VERSION="3.1.0-DEV5"

if [ ! -f src/varseq/varseq.tar.gz ]; then
  echo "Missing src/varseq/varseq.tar.gz" >&2
  echo "Stage it with:" >&2
  echo "  cp /mnt/mindshare/Products/Builds/Installers/VarSeq-Lin64-${VS_VERSION}.tar.gz src/varseq/varseq.tar.gz" >&2
  exit 1
fi

OFFICE_WEB_MANIFEST="LAST_BUILD.tag"
if [ -z "${OFFICE_WEB_TAG:-}" ]; then
  if [ ! -f "${OFFICE_WEB_MANIFEST}" ]; then
    echo "Error: ${OFFICE_WEB_MANIFEST} not found and OFFICE_WEB_TAG not set." >&2
    echo "Build office-web first (./build-trixie.sh)" >&2
    echo "or pin a specific tag: OFFICE_WEB_TAG=260518 ./build-varseq-trixie.sh" >&2
    exit 1
  fi
  OFFICE_WEB_TAG=$(cat "${OFFICE_WEB_MANIFEST}")
fi
echo "Using ghdesktop-office-web:${OFFICE_WEB_TAG} as base"

docker build \
  -t ${REGISTRY}/ghdesktop-varseq-trixie:$(arch)-${DAY} \
  -t ${REGISTRY}/ghdesktop-varseq-trixie:latest \
  --build-arg BASE_IMAGE="${REGISTRY}/ghdesktop-office-web" \
  --build-arg BASE_TAG="${OFFICE_WEB_TAG}" \
  --build-arg VS_VERSION="${VS_VERSION}" \
  -f dockerfile-gh-varseq-bake .
