#!/bin/bash
set -eu -o pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: mypy.sh image_name [options ...] [files ...]"
  exit 1
fi
IMAGE_NAME="$1"
readonly IMAGE_NAME
shift

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
else
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
fi
