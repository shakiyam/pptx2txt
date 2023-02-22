#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $# -eq 0 ]]; then
  echo_error 'Usage: mypy.sh image_name [options ...] [files ...]'
  exit 1
fi
IMAGE_NAME="$1"
readonly IMAGE_NAME
shift

[[ -d "$PWD"/.mypy_cache ]] || mkdir "$PWD"/.mypy_cache
if [[ $(command -v docker) ]]; then
  docker container run \
    --entrypoint /usr/local/bin/mypy \
    --name mypy$$ \
    --rm \
    -t \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -v "$PWD"/.mypy_cache:/work/.mypy_cache \
    -w /work \
    "$IMAGE_NAME" "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --entrypoint /usr/local/bin/mypy \
    --name mypy$$ \
    --rm \
    --security-opt label=disable \
    -t \
    -v "$PWD":/work:ro \
    -v "$PWD"/.mypy_cache:/work/.mypy_cache \
    -w /work \
    "$IMAGE_NAME" "$@"
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
