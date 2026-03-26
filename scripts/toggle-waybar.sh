#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

if ! pidof waybar >/dev/null 2>&1; then
  waybar -c "$NIRICONF/waybar/config" -s "$NIRICONF/waybar/style.css" &
else
  pkill waybar
fi
