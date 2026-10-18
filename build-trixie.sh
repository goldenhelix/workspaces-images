#!/bin/bash
# Build ghdesktop-office-web on the trixie core.
#
# Tags:
#   ghdesktop-office-web-trixie:$(arch)-$DAY  ← variant-specific, dated
#   ghdesktop-office-web-trixie:latest         ← variant-specific, moving
#   ghdesktop-office-web:$DAY                  ← unsuffixed, dated (reproducible base)
#   ghdesktop-office-web:latest                ← unsuffixed, moving
#
# Base: ghdesktop-core:$CORE_TAG (dated, NOT :latest, for reproducibility).
# CORE_TAG is read from ../workspaces-core-images/LAST_BUILD.tag by
# default; override via env var: CORE_TAG=260518 ./build-trixie.sh
#
# Trixie is the only variant we actively maintain — the unsuffixed tag
# IS the trixie build.

set -euo pipefail

REGISTRY=registry.goldenhelix.com/public
DAY=$(date +'%y%m%d')

CORE_MANIFEST="../workspaces-core-images/LAST_BUILD.tag"
if [ -z "${CORE_TAG:-}" ]; then
  if [ ! -f "${CORE_MANIFEST}" ]; then
    echo "Error: ${CORE_MANIFEST} not found and CORE_TAG not set." >&2
    echo "Build the core first (./build-trixie.sh in ../workspaces-core-images)" >&2
    echo "or pin a specific tag: CORE_TAG=260518 ./build-trixie.sh" >&2
    exit 1
  fi
  CORE_TAG=$(cat "${CORE_MANIFEST}")
fi
echo "Using ghdesktop-core:${CORE_TAG} as base"

docker build \
  -t ${REGISTRY}/ghdesktop-office-web-trixie:$(arch)-${DAY} \
  -t ${REGISTRY}/ghdesktop-office-web-trixie:latest \
  -t ${REGISTRY}/ghdesktop-office-web:${DAY} \
  -t ${REGISTRY}/ghdesktop-office-web:latest \
  --build-arg BASE_IMAGE="${REGISTRY}/ghdesktop-core" \
  --build-arg BASE_TAG="${CORE_TAG}" \
  -f dockerfile-gh-office-web .

echo "${DAY}" > LAST_BUILD.tag
echo "Wrote LAST_BUILD.tag: ${DAY}"
