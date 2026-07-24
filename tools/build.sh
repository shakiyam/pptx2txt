#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE

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

CURRENT_IMAGE="$($CONTAINER_ENGINE image ls --quiet --no-trunc "$IMAGE_NAME":latest)"
readonly CURRENT_IMAGE
SOURCE_COMMIT="$(git rev-parse HEAD || :)"
readonly SOURCE_COMMIT
$CONTAINER_ENGINE image build --build-arg SOURCE_COMMIT="$SOURCE_COMMIT" -f "$DOCKERFILE" -t "$IMAGE_NAME" .
LATEST_IMAGE="$($CONTAINER_ENGINE image ls --quiet --no-trunc "$IMAGE_NAME":latest)"
readonly LATEST_IMAGE
if [[ "$CURRENT_IMAGE" != "$LATEST_IMAGE" ]]; then
  $CONTAINER_ENGINE image tag "$IMAGE_NAME":latest "$IMAGE_NAME":"$(date +%Y%m%d%H%M%S)"
fi
