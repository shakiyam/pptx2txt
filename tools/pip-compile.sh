#!/bin/bash
set -eu -o pipefail

if [[ $(command -v podman) ]]; then
  podman container run \
    --name pip-compile$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work \
    -w /work \
    -e HOME=/tmp \
    docker.io/shakiyam/pip-tools pip-compile "$@"
else
  docker container run \
    --name pip-compile$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work \
    -w /work \
    -e HOME=/tmp \
    shakiyam/pip-tools pip-compile "$@"
fi
