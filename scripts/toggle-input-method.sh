#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"

if have_cmd fcitx5-remote; then
  state="$(fcitx5-remote || true)"
  case "$state" in
    1) fcitx5-remote -c ;;
    2) fcitx5-remote -c ;;
    *) fcitx5-remote -o ;;
  esac
  exit 0
fi

if have_cmd ibus; then
  current="$(ibus engine 2>/dev/null || true)"
  if [ "$current" = "xkb:us::eng" ]; then
    next_engine="$(ibus list-engine | awk '/^language: zh/ {found=1} found && /^name:/ {print $2; exit}')"
    [ -n "$next_engine" ] || next_engine="libpinyin"
    ibus engine "$next_engine"
  else
    ibus engine xkb:us::eng
  fi
  exit 0
fi

echo "[ERROR] no supported input method tool found (tried fcitx5-remote, ibus)" >&2
exit 1
