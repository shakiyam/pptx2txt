#!/bin/bash
set -eu -o pipefail

if [[ $(command -v podman) ]]; then
  podman container run \
    --name shfmt$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/mvdan/shfmt:latest "$@"
else
  docker container run \
    --name shfmt$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -w /work \
    mvdan/shfmt:latest "$@"
fi
