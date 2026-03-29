#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"

case "$action" in
  raise)
    if command -v wpctl >/dev/null 2>&1; then
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    elif command -v pactl >/dev/null 2>&1; then
      pactl set-sink-volume @DEFAULT_SINK@ +5%
    elif command -v amixer >/dev/null 2>&1; then
      amixer set Master 5%+
    fi
    ;;
  lower)
    if command -v wpctl >/dev/null 2>&1; then
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    elif command -v pactl >/dev/null 2>&1; then
      pactl set-sink-volume @DEFAULT_SINK@ -5%
    elif command -v amixer >/dev/null 2>&1; then
      amixer set Master 5%-
    fi
    ;;
  mute)
    if command -v wpctl >/dev/null 2>&1; then
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    elif command -v pactl >/dev/null 2>&1; then
      pactl set-sink-mute @DEFAULT_SINK@ toggle
    elif command -v amixer >/dev/null 2>&1; then
      amixer set Master toggle
    fi
    ;;
  *)
    echo "[ERROR] usage: volume.sh raise|lower|mute" >&2
    exit 1
    ;;
esac
