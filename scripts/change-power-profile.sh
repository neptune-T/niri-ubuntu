#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

options="power-saver\nbalanced\nperformance"
choice=$(echo -e "$options" | fuzzel --dmenu --lines 3 -w 20 --config "$NIRICONF/fuzzel/power-profile.ini")

if [ -n "$choice" ]; then
  powerprofilesctl set "$choice"
fi
