#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v docker &>/dev/null; then
  docker container run \
    --name "flake8_$(uuidgen | head -c8)" \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/flake8 "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name "flake8_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/flake8 "$@"
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
