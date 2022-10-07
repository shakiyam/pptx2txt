#!/bin/bash
set -eu -o pipefail

case "$#" in
  1)
    IMAGE_NAME="$1"
    DOCKERFILE=Dockerfile
    ;;
  2)
    IMAGE_NAME="$1"
    DOCKERFILE="$2"
    ;;
  *)
    echo "Usage: build.sh image_name [Dockerfile]"
    exit 1
    ;;
esac
readonly IMAGE_NAME
readonly DOCKERFILE

DOCKER=$(command -v docker || command -v podman)
readonly DOCKER
CURRENT_IMAGE="$($DOCKER image inspect -f "{{.Id}}" "$IMAGE_NAME":latest || :)"
readonly CURRENT_IMAGE
$DOCKER image build -f "$DOCKERFILE" -t "$IMAGE_NAME" .
LATEST_IMAGE="$($DOCKER image inspect -f "{{.Id}}" "$IMAGE_NAME":latest || :)"
readonly LATEST_IMAGE
if [[ "$CURRENT_IMAGE" != "$LATEST_IMAGE" ]]; then
  $DOCKER image tag "$IMAGE_NAME":latest "$IMAGE_NAME":"$(date +%Y%m%d%H%S)"
fi
