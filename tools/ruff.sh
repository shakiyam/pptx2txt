#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v ruff &>/dev/null; then
  ruff "$@"
elif command -v docker &>/dev/null; then
  docker container run \
    --name "ruff_$(uuidgen | head -c8)" \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/io \
    ghcr.io/astral-sh/ruff:latest "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name "ruff_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/io \
    ghcr.io/astral-sh/ruff:latest "$@"
else
  echo_error 'ruff could not be executed.'
  exit 1
fi
