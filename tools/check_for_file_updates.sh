#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ -n $(git diff "$@") ]]; then
  echo_error "File updates detected:"
  git --no-pager diff "$@"
  exit 2
fi
echo_success "No file changes detected."
