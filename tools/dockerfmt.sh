#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

if command -v dockerfmt &>/dev/null; then
  DOCKERFMT=dockerfmt
else
  DOCKERFMT="$SCRIPT_DIR"/dockerfmt
  if [[ ! -x "$DOCKERFMT" ]]; then
    echo_warn "Required dependency 'dockerfmt' is missing, download it."
    case $(uname -m) in
      x86_64)
        ARCHITECTURE=amd64
        ;;
      aarch64)
        ARCHITECTURE=arm64
        ;;
      *)
        echo_error "Error: Unsupported architecture: $(uname -m)"
        exit 1
        ;;
    esac
    readonly ARCHITECTURE
    LATEST=$(
      curl -sSI https://github.com/reteps/dockerfmt/releases/latest \
        | tr -d '\r' \
        | awk -F'/' '/^[Ll]ocation:/{print $NF}'
    )
    readonly LATEST
    curl -fL# "https://github.com/reteps/dockerfmt/releases/download/${LATEST}/dockerfmt-${LATEST}-linux-${ARCHITECTURE}.tar.gz" \
      | tar xzf - -O dockerfmt \
      | install -m 755 /dev/stdin "$DOCKERFMT"
  fi
fi
readonly DOCKERFMT

"$DOCKERFMT" "$@"
