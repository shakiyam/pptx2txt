#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $# -ne 2 && $# -ne 3 ]]; then
  echo_error "Usage: check_for_new_release.sh repository current_release [pattern]"
  exit 1
fi

readonly REPOSITORY=$1
readonly CURRENT_RELEASE=$2
if [[ $# -eq 3 ]]; then
  PATTERN=$3
else
  PATTERN='.+'
fi
readonly PATTERN
LATEST_RELEASE=$(
  curl -sSI "https://github.com/$REPOSITORY/releases/latest" \
    | tr -d '\r' \
    | awk -F'/' '/^[Ll]ocation:/{print $NF}'
)
readonly LATEST_RELEASE
CURRENT_VERSION_PART=$(echo "$CURRENT_RELEASE" | grep -E -o "$PATTERN")
readonly CURRENT_VERSION_PART
LATEST_VERSION_PART=$(echo "$LATEST_RELEASE" | grep -E -o "$PATTERN")
readonly LATEST_VERSION_PART
if [[ "$CURRENT_VERSION_PART" != "$LATEST_VERSION_PART" ]]; then
  echo_warn "$REPOSITORY $CURRENT_RELEASE is not the latest release. The latest release is $LATEST_RELEASE."
  exit 2
fi
echo_success "$REPOSITORY $CURRENT_RELEASE is the latest release."
