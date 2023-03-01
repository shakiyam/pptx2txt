#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $(command -v docker) ]]; then
  docker container run \
    --name flake8$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/flake8 "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name flake8$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/flake8 "$@"
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
