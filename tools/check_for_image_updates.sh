#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

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

if command -v regctl &>/dev/null; then
  REGCTL=regctl
else
  REGCTL="$SCRIPT_DIR"/regctl
  if [[ ! -x "$REGCTL" ]]; then
    echo_warn "Required dependency 'regctl' is missing, download it."
    LATEST=$(
      curl -sSI https://github.com/regclient/regclient/releases/latest \
        | tr -d '\r' \
        | awk -F'/' '/^[Ll]ocation:/{print $NF}'
    )
    readonly LATEST
    curl -L# "https://github.com/regclient/regclient/releases/download/${LATEST}/regctl-linux-${ARCHITECTURE}" >"$REGCTL"
    chmod +x "$REGCTL"
  fi
fi
readonly REGCTL

if [[ $# -ne 2 ]]; then
  echo_error "Usage: check_for_image_updates.sh image_name1 image_name2"
  exit 1
fi
readonly IMAGE_NAME1=$1
readonly IMAGE_NAME2=$2

echo_info "$IMAGE_NAME1 and $IMAGE_NAME2"
IMAGE_DIGEST1="$("$REGCTL" manifest digest -p "linux/${ARCHITECTURE}" "$IMAGE_NAME1")"
readonly IMAGE_DIGEST1
IMAGE_DIGEST2="$("$REGCTL" manifest digest -p "linux/${ARCHITECTURE}" "$IMAGE_NAME2")"
readonly IMAGE_DIGEST2
if [[ "$IMAGE_DIGEST1" != "$IMAGE_DIGEST2" ]]; then
  echo_warn "$IMAGE_NAME1 and $IMAGE_NAME2 are not the same."
  exit 2
fi
echo_success "$IMAGE_NAME1 and $IMAGE_NAME2 are the same."
