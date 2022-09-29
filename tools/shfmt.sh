#!/bin/bash
set -eu -o pipefail

if [[ $(command -v shfmt) ]]; then
  shfmt "$@"
elif [[ $(command -v docker) ]]; then
  docker container run \
    --name shfmt$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/mvdan/shfmt:latest "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name shfmt$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/mvdan/shfmt:latest "$@"
else
  echo -e "\033[36mshfmt could not be executed.\033[0m"
  exit 1
fi
