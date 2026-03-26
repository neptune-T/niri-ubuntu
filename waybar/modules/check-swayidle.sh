#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/../../scripts/common.sh"

mkdir -p "$(state_dir)"
if [ ! -f "$(idle_time_file)" ]; then
  printf '10 minutes\n' >"$(idle_time_file)"
fi

mode="$(cat "$(idle_time_file)")"
case $mode in
  "5 minutes")
    printf '{"text": " 5m", "alt": "swayidle enabled", "tooltip": "swayidle enabled"}'
    ;;
  "10 minutes")
    printf '{"text": " 10m", "alt": "swayidle enabled", "tooltip": "swayidle enabled"}'
    ;;
  "20 minutes")
    printf '{"text": " 20m", "alt": "swayidle enabled", "tooltip": "swayidle enabled"}'
    ;;
  "30 minutes")
    printf '{"text": " 30m", "alt": "swayidle enabled", "tooltip": "swayidle enabled"}'
    ;;
  "infinity")
    printf '{"text": " inf", "alt": "swayidle disabled", "tooltip": "swayidle disabled"}'
    ;;
  *)
    printf '{"text": " err", "alt": "idle-time not found", "tooltip": "idle-time not found"}'
    ;;
esac
