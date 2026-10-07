#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

CI_CONFIG_MOUNT=()
if [[ -f .dive-ci ]]; then
  CI_CONFIG_MOUNT=(-v "$PWD/.dive-ci":/.dive-ci:ro)
fi
readonly CI_CONFIG_MOUNT

if command -v dive &>/dev/null; then
  dive "$@"
else
  CONTAINER_ENGINE=$(detect_container_engine)
  readonly CONTAINER_ENGINE
  if [[ $CONTAINER_ENGINE == docker ]]; then
    ENGINE_OPTS=(-v /var/run/docker.sock:/var/run/docker.sock:ro)
  else
    PODMAN_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
    readonly PODMAN_SOCKET
    if [[ ! -S "$PODMAN_SOCKET" ]]; then
      echo_error "Podman socket not found: $PODMAN_SOCKET"
      echo_error "Run: systemctl --user enable --now podman.socket"
      exit 1
    fi
    ENGINE_OPTS=(
      --security-opt label=disable
      -v "$PODMAN_SOCKET":/run/podman/podman.sock:ro
      -e DOCKER_HOST=unix:///run/podman/podman.sock
    )
  fi
  readonly ENGINE_OPTS

  $CONTAINER_ENGINE container run \
    --name "dive_$(uuidgen | head -c8)" \
    --rm \
    "${ENGINE_OPTS[@]}" \
    "${CI_CONFIG_MOUNT[@]}" \
    ghcr.io/wagoodman/dive "$@"
fi
