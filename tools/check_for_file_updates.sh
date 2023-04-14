#!/bin/bash
set -eu -o pipefail

if [[ -n $(git diff "$@") ]]; then
  git --no-pager diff "$@"
  exit 2
fi
