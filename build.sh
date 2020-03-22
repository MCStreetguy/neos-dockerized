#!/bin/bash

set -e

if [ "$1" == "--no-publish" ]; then
  declare -r NOPUBLISH=true
  shift 1
elif [ "$1" == "--push-only" ]; then
  declare -r PUSHONLY=true
  shift 1
fi

declare -r TAG_NAME="mcstreetguy/neos-dockerized"

if [ "$#" -eq 1 ]; then
  declare NEOS_VERSION="$1"

  if [ "$NEOS_VERSION" == "dev-master" ]; then
    declare TAG_VERSION="latest"
  else
    declare TAG_VERSION="${NEOS_VERSION:1}"
  fi

  export NEOS_VERSION
  export TAG_VERSION

  if [ "$NOPUBLISH" ]; then
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --tag "${TAG_NAME}:${TAG_VERSION}" --compress --force-rm --pull --build-arg NEOS_VERSION .
  elif [ "$PUSHONLY" ]; then
    docker push "${TAG_NAME}:${TAG_VERSION}"
  else
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --tag "${TAG_NAME}:${TAG_VERSION}" --compress --force-rm --pull --build-arg NEOS_VERSION .
    docker push "${TAG_NAME}:${TAG_VERSION}"
  fi

  unset TAG_VERSION
  unset NEOS_VERSION

  echo "Done." >&2
  exit 0
elif [ "$#" -ne 0 ]; then
  echo "ERROR! Wrong argument count!" >&2
  exit 1
fi

declare -ar NEOS_VERSION_TARGETS=( "^3.3" "^4.3" "dev-master" )

for NEOS_VERSION in "${NEOS_VERSION_TARGETS[@]}"; do
  if [ "$NEOS_VERSION" == "dev-master" ]; then
    declare TAG_VERSION="latest"
  else
    declare TAG_VERSION="${NEOS_VERSION:1}"
  fi

  export NEOS_VERSION
  export TAG_VERSION

  if [ "$NOPUBLISH" ]; then
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --tag "${TAG_NAME}:${TAG_VERSION}" --compress --force-rm --pull --build-arg NEOS_VERSION .
  elif [ "$PUSHONLY" ]; then
    docker push "${TAG_NAME}:${TAG_VERSION}"
  else
    echo "[INFO] Building '${TAG_NAME}:${TAG_VERSION}' ..." >&2
    docker build --tag "${TAG_NAME}:${TAG_VERSION}" --compress --force-rm --pull --build-arg NEOS_VERSION .
    docker push "${TAG_NAME}:${TAG_VERSION}"
  fi

  unset TAG_VERSION
  unset NEOS_VERSION
done

echo "Done." >&2
exit 0
