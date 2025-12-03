#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if [[ $# -ne 1 && $# -ne 2 ]]; then
  echo_error "Usage: check_for_action_updates.sh action_name [version_pattern]"
  exit 1
fi

readonly ACTION=$1
readonly VERSION_PATTERN=${2:-'(v[0-9]+)'}
readonly WORKFLOW_DIR=.github/workflows

VERSIONS=$(
  grep -r "^\s*uses:.*${ACTION}@" "$WORKFLOW_DIR" --include="*.yml" --include="*.yaml" 2>/dev/null \
    | awk -F'@' '{print $2}' \
    | sort -u
)

for version in $VERSIONS; do
  "$SCRIPT_DIR/check_for_new_release.sh" "$ACTION" "$version" "$VERSION_PATTERN"
done
