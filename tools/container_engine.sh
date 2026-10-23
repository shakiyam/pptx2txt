# shellcheck shell=bash
# Requires colored_echo.sh to be sourced first.

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

healthcheck_status_query() {
  local engine
  engine=$(detect_container_engine) || return
  if [[ $engine == docker ]]; then
    echo '{{.State.Health.Status}}'
  else
    echo '{{.State.Healthcheck.Status}}'
  fi
}
