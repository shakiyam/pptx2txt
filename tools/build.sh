#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v docker &>/dev/null; then
  DOCKER=docker
elif command -v podman &>/dev/null; then
  DOCKER=podman
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
readonly DOCKER

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
    echo_error 'Usage: build.sh image_name [Dockerfile]'
    exit 1
    ;;
esac
readonly IMAGE_NAME
readonly DOCKERFILE

CURRENT_IMAGE="$($DOCKER image inspect -f "{{.Id}}" "$IMAGE_NAME":latest || :)"
readonly CURRENT_IMAGE
$DOCKER image build -f "$DOCKERFILE" -t "$IMAGE_NAME" .
LATEST_IMAGE="$($DOCKER image inspect -f "{{.Id}}" "$IMAGE_NAME":latest || :)"
readonly LATEST_IMAGE
if [[ "$CURRENT_IMAGE" != "$LATEST_IMAGE" ]]; then
  $DOCKER image tag "$IMAGE_NAME":latest "$IMAGE_NAME":"$(date +%Y%m%d%H%S)"
fi
