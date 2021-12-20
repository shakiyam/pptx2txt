#!/bin/bash
set -eu -o pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: mypy.sh image_name [options ...] [files ...]"
  exit 1
fi
IMAGE_NAME="$1"
readonly IMAGE_NAME
shift

if [[ $(command -v podman) ]]; then
  podman container run \
    --name mypy$$ \
    -t \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -v "$PWD"/.mypy_cache:/work/.mypy_cache \
    -w /work \
    --entrypoint /usr/local/bin/mypy \
    "$IMAGE_NAME" "$@"
else
  docker container run \
    --name mypy$$ \
    -t \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -v "$PWD"/.mypy_cache:/work/.mypy_cache \
    -w /work \
    --entrypoint /usr/local/bin/mypy \
    "$IMAGE_NAME" "$@"
fi
