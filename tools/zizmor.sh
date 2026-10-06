#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

if command -v zizmor &>/dev/null; then
  zizmor "$@"
else
  CONTAINER_ENGINE=$(detect_container_engine)
  readonly CONTAINER_ENGINE
  if [[ $CONTAINER_ENGINE == docker ]]; then
    ENGINE_OPTS=(-u "$(id -u):$(id -g)")
  else
    ENGINE_OPTS=(--security-opt label=disable)
  fi
  if [[ -n "${GH_TOKEN:-}" ]]; then
    ENGINE_OPTS+=(-e GH_TOKEN)
  fi
  readonly ENGINE_OPTS

  $CONTAINER_ENGINE container run \
    --name "zizmor_$(uuidgen | head -c8)" \
    --rm \
    "${ENGINE_OPTS[@]}" \
    --tmpfs /tmp \
    -e XDG_CACHE_HOME=/tmp \
    -v "$PWD":/work:ro \
    -w /work \
    ghcr.io/zizmorcore/zizmor:latest "$@"
fi
