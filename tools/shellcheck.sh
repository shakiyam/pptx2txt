#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v shellcheck &>/dev/null; then
  shellcheck "$@"
elif command -v docker &>/dev/null; then
  docker container run \
    --name shellcheck$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/mnt:ro \
    docker.io/koalaman/shellcheck:stable "$@"
elif command -v podman &>/dev/null; then
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
