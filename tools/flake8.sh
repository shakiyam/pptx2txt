#!/bin/bash
set -eu -o pipefail

if [[ $(command -v docker) ]]; then
  docker container run \
    --name flake8$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    docker.io/shakiyam/flake8 "$@"
else
  podman container run \
    --name flake8$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    docker.io/shakiyam/flake8 "$@"
fi
