#!/bin/bash
set -eu -o pipefail

if [[ $(command -v shellcheck) ]]; then
  shellcheck "$@"
elif [[ $(command -v docker) ]]; then
  docker container run \
    --name shellcheck$$ \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/mnt:ro \
    docker.io/koalaman/shellcheck:stable "$@"
elif [[ $(command -v podman) ]]; then
  podman container run \
    --name shellcheck$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/mnt:ro \
    docker.io/koalaman/shellcheck:stable "$@"
else
  echo -e "\033[36mshellcheck could not be executed.\033[0m"
  exit 1
fi
