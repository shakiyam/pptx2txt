#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

if command -v markdownlint-cli2 &>/dev/null; then
  markdownlint-cli2 "$@"
else
  CONTAINER_ENGINE=$(detect_container_engine)
  readonly CONTAINER_ENGINE
  if [[ $CONTAINER_ENGINE == docker ]]; then
    ENGINE_OPTS=(-u "$(id -u):$(id -g)")
  else
    ENGINE_OPTS=(--security-opt label=disable)
  fi
  readonly ENGINE_OPTS

  $CONTAINER_ENGINE container run \
    --name "markdownlint_$(uuidgen | head -c8)" \
    --rm \
    "${ENGINE_OPTS[@]}" \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/davidanson/markdownlint-cli2:latest "$@"
fi
