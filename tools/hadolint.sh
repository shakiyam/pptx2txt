#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $(command -v hadolint) ]]; then
  hadolint "$@"
elif [[ $(command -v docker) ]]; then
  docker container run \
    --name hadolint$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -w /work \
    ghcr.io/hadolint/hadolint hadolint "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name hadolint$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -w /work \
    ghcr.io/hadolint/hadolint hadolint "$@"
else
  echo_error 'hadolint could not be executed.'
  exit 1
fi
