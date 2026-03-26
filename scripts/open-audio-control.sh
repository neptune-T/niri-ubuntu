#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"

if audio_control=$(first_cmd pwvucontrol pavucontrol); then
  exec "$audio_control"
fi

echo "[ERROR] no audio control app found (tried: pwvucontrol, pavucontrol)" >&2
exit 1
