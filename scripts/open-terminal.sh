#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

profile="${1:-default}"
shift || true

title="${1:-}"
if [ "$#" -gt 0 ]; then
  shift
fi

if have_cmd alacritty; then
  if [ "$#" -gt 0 ]; then
    exec alacritty --title "$title" --config-file "$NIRICONF/alacritty/${profile}.toml" -e "$@"
  fi

  exec alacritty --config-file "$NIRICONF/alacritty/${profile}.toml"
fi

if have_cmd kitty; then
  if [ "$#" -gt 0 ]; then
    exec kitty --title "$title" "$@"
  fi

  exec kitty
fi

if have_cmd foot; then
  if [ "$#" -gt 0 ]; then
    exec foot -T "$title" "$@"
  fi

  exec foot
fi

if have_cmd gnome-terminal; then
  if [ "$#" -gt 0 ]; then
    exec gnome-terminal --title="$title" -- "$@"
  fi

  exec gnome-terminal --title="$title"
fi

if have_cmd kgx; then
  if [ "$#" -gt 0 ]; then
    exec kgx --title "$title" "$@"
  fi

  exec kgx
fi

echo "[ERROR] no supported terminal found" >&2
exit 1
