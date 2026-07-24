#!/bin/bash
# Sourced library. Requires colored_echo.sh to be sourced first.

detect_container_engine() {
  if command -v docker &>/dev/null; then
    echo docker
  elif command -v podman &>/dev/null; then
    echo podman
  else
    echo_error 'Neither docker nor podman is installed.'
    return 1
  fi
}
