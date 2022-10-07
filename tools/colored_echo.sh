#!/bin/bash
set -eu -o pipefail

echo_error() {
  if [[ -t 1 ]]; then
    tput setaf 1 # Red
    tput bold
  fi
  echo "$@"
  if [[ -t 1 ]]; then
    tput sgr0
  fi
}

echo_warn() {
  if [[ -t 1 ]]; then
    tput setaf 3 # Yellow
    tput bold
  fi
  echo "$@"
  if [[ -t 1 ]]; then
    tput sgr0
  fi
}

echo_info() {
  if [[ -t 1 ]]; then
    tput setaf 6 # Cyan
  fi
  echo "$@"
  if [[ -t 1 ]]; then
    tput sgr0
  fi
}

echo_success() {
  if [[ -t 1 ]]; then
    tput setaf 2 # Green
  fi
  echo "$@"
  if [[ -t 1 ]]; then
    tput sgr0
  fi
}
