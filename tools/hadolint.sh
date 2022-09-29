#!/bin/bash
set -eu -o pipefail

if [[ $(command -v hadolint) ]]; then
  hadolint "$@"
elif [[ $(command -v docker) ]]; then
  docker container run \
    --name hadolint$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/hadolint/hadolint hadolint "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name hadolint$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -w /work \
    docker.io/hadolint/hadolint hadolint "$@"
else
  echo -e "\033[36hadolint could not be executed.\033[0m"
  exit 1
fi
