#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $(command -v shellcheck) ]]; then
  shellcheck "$@"
elif [[ $(command -v docker) ]]; then
  docker container run \
    --name shellcheck$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/mnt:ro \
    docker.io/koalaman/shellcheck:stable "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name shellcheck$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/mnt:ro \
    docker.io/koalaman/shellcheck:stable "$@"
else
  echo_error 'shellcheck could not be executed.'
  exit 1
fi
