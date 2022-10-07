#!/bin/bash
set -eu -o pipefail

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
  echo 'Neither docker nor podman is installed.'
  exit 1
fi
