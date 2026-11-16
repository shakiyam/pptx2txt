#!/bin/bash
set -Eeu -o pipefail

cd "$(dirname "$0")"
# shellcheck disable=SC1091
. ../tools/colored_echo.sh
# shellcheck disable=SC1091
. ../tools/container_engine.sh

# Started without the wrapper's -u, the image itself must not run as root
CONTAINER_ENGINE=$(detect_container_engine)
IMAGE_UID=$($CONTAINER_ENGINE container run --rm --entrypoint id ghcr.io/shakiyam/pptx2txt -u)
if [[ $IMAGE_UID == 0 ]]; then
  echo_error 'The pptx2txt image runs as root.'
  exit 1
fi

../pptx2txt sample1.pptx sample2.pptx sample3.pptx
diff sample1.txt expected/sample1.txt
diff sample2.txt expected/sample2.txt
diff sample3.txt expected/sample3.txt
