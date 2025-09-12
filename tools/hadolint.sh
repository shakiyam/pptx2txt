#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v hadolint &>/dev/null; then
  hadolint "$@"
elif command -v docker &>/dev/null; then
  docker container run \
    --name "hadolint_$(uuidgen | head -c8)" \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    -w /work \
    ghcr.io/hadolint/hadolint hadolint "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name "hadolint_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -v "$PWD":/work:ro \
    -w /work \
    ghcr.io/hadolint/hadolint hadolint "$@"
else
  echo_error 'hadolint could not be executed.'
  exit 1
fi
