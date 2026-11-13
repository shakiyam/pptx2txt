#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

if command -v actionlint &>/dev/null; then
  actionlint "$@"
else
  CONTAINER_ENGINE=$(detect_container_engine)
  readonly CONTAINER_ENGINE
  if [[ $CONTAINER_ENGINE == docker ]]; then
    ENGINE_OPTS=(-u "$(id -u):$(id -g)")
  else
    # The image runs as a non-root USER, which rootless Podman maps to a subuid that
    # cannot read the caller's private files; keep-id plus -u runs as the caller instead.
    ENGINE_OPTS=(--security-opt label=disable --userns=keep-id -u "$(id -u):$(id -g)")
  fi
  readonly ENGINE_OPTS

  $CONTAINER_ENGINE container run \
    --name "actionlint_$(uuidgen | head -c8)" \
    --rm \
    "${ENGINE_OPTS[@]}" \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/rhysd/actionlint:latest "$@"
fi
