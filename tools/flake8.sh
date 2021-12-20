#!/bin/bash
set -eu -o pipefail

if [[ $(command -v podman) ]]; then
  podman container run \
    --name flake8$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    docker.io/shakiyam/flake8 "$@"
else
  docker container run \
    --name flake8$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    shakiyam/flake8 "$@"
fi
