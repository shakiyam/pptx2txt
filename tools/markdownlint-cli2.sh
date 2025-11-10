#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v markdownlint-cli2 &>/dev/null; then
  markdownlint-cli2 "$@"
elif command -v docker &>/dev/null; then
  docker container run \
    --name "markdownlint_$(uuidgen | head -c8)" \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/davidanson/markdownlint-cli2:latest "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name "markdownlint_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/davidanson/markdownlint-cli2:latest "$@"
else
  echo_error 'markdownlint-cli2 could not be executed.'
  exit 1
fi
