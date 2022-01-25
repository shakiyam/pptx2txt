#!/bin/bash
set -eu -o pipefail

if [[ $(uname -m) == 'aarch64' ]]; then
  echo 'hadolint is not yet supported on ARM.'
  exit 0
fi

if [[ $(command -v docker) ]]; then
  docker container run \
    --name hadolint$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/hadolint/hadolint hadolint "$@"
else
  podman container run \
    --name hadolint$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/hadolint/hadolint hadolint "$@"
fi
