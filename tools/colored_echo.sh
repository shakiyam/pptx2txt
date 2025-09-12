#!/bin/bash
set -Eeu -o pipefail

echo_error() {
  if [[ -t 2 ]]; then
    echo -e "\033[1;31m$*\033[0m" >&2 # Bold Red
  else
    echo "$@" >&2
  fi
}

echo_warn() {
  if [[ -t 2 ]]; then
    echo -e "\033[1;33m$*\033[0m" >&2 # Bold Yellow
  else
    echo "$@" >&2
  fi
}

echo_info() {
  if [[ -t 1 ]]; then
    echo -e "\033[36m$*\033[0m" # Cyan
  else
    echo "$@"
  fi
}

echo_success() {
  if [[ -t 1 ]]; then
    echo -e "\033[32m$*\033[0m" # Green
  else
    echo "$@"
  fi
}
