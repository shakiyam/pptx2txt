#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $(command -v docker) ]]; then
  docker container run \
    --name pip-compile$$ \
    --rm \
    -e HOME=/tmp \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work \
    -w /work \
    docker.io/shakiyam/pip-tools pip-compile "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name pip-compile$$ \
    --rm \
    --security-opt label=disable \
    -e HOME=/tmp \
    -v "$PWD":/work \
    -w /work \
    docker.io/shakiyam/pip-tools pip-compile "$@"
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
