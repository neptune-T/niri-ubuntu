#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

modes="5 minutes\n10 minutes\n20 minutes\n30 minutes\ninfinity"
choice=$(echo -e "$modes" | "$NIRICONF/scripts/menu.sh" dmenu --lines 5 -w 20 --config "$NIRICONF/fuzzel/idle-time.ini")

if [ -n "$choice" ]; then
  mkdir -p "$(state_dir)"
  pkill -x swayidle || true
  printf '%s\n' "$choice" >"$(idle_time_file)"
  bash "$NIRICONF/scripts/swayidle.sh" &
  disown
fi
