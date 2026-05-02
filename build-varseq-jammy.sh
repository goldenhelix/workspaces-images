#!/bin/bash
# Build ghdesktop-varseq-jammy (VarSeq DEV5 baked in, ubuntu 22.04).

REGISTRY=registry.goldenhelix.com/public
DAY=$(date +'%y%m%d')
VS_VERSION="3.1.0-DEV5"

if [ ! -f src/varseq/varseq.tar.gz ]; then
  echo "Missing src/varseq/varseq.tar.gz" >&2
  echo "Stage it with:" >&2
  echo "  cp /mnt/mindshare/Products/Builds/Installers/VarSeq-Lin64-${VS_VERSION}.tar.gz src/varseq/varseq.tar.gz" >&2
  exit 1
fi

docker build \
  -t ${REGISTRY}/ghdesktop-varseq-jammy:$(arch)-${DAY} \
  -t ${REGISTRY}/ghdesktop-varseq-jammy:latest \
  --build-arg BASE_IMAGE="${REGISTRY}/ghdesktop-office-web-jammy" \
  --build-arg BASE_TAG="latest" \
  --build-arg VS_VERSION="${VS_VERSION}" \
  -f dockerfile-gh-varseq .
