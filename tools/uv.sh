#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

readonly UV_IMAGE="ghcr.io/astral-sh/uv:0.9.9-python3.14-trixie-slim"

if command -v docker &>/dev/null; then
  docker container run \
    --name "uv_$(uuidgen | head -c8)" \
    --rm \
    -e HOME=/tmp \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work \
    -w /work \
    "$UV_IMAGE" uv "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name "uv_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -e HOME=/tmp \
    -v "$PWD":/work \
    -w /work \
    "$UV_IMAGE" uv "$@"
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
