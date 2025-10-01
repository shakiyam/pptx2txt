#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if ! DIFF_OUTPUT=$(git diff "$@" 2>&1); then
  echo_error "Error running git diff: $DIFF_OUTPUT"
  exit 1
fi

if [[ -n $DIFF_OUTPUT ]]; then
  echo_error "File updates detected:"
  echo "$DIFF_OUTPUT"
  exit 2
fi
echo_success "No file changes detected."
