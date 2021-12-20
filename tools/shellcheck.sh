#!/bin/bash
set -eu -o pipefail

if [[ $(command -v podman) ]]; then
  podman container run \
    --name shellcheck$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/mnt:ro \
    docker.io/koalaman/shellcheck:stable "$@"
else
  docker container run \
    --name shellcheck$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/mnt:ro \
    koalaman/shellcheck:stable "$@"
fi
