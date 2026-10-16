# shellcheck shell=bash
# Requires colored_echo.sh to be sourced first.

get_github_latest_release() {
  local -r repository=$1
  # Read the tag from the redirect instead of the REST API, whose unauthenticated rate limit is shared per IP address
  local tag
  if ! tag=$(curl -sSI --proto '=https' --tlsv1.2 "https://github.com/${repository}/releases/latest" \
    | tr -d '\r' \
    | awk -F'/' '/^[Ll]ocation:.*\/releases\/tag\//{print $NF}'); then
    echo_error "Failed to fetch the latest release of ${repository}."
    return 1
  fi
  if [[ -z "$tag" ]]; then
    echo_error "No release found for ${repository}."
    return 1
  fi
  echo "$tag"
}
