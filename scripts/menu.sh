#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

mode="${1:-launcher}"
shift || true

if have_cmd fuzzel; then
  case "$mode" in
    launcher)
      # Prefer gtk-launch for reliable desktop-entry execution on Ubuntu
      # (handles Snap, Flatpak, and apps with complex Exec fields correctly).
      # fuzzel --print-only prints the desktop entry ID instead of exec-ing it.
      if have_cmd gtk-launch; then
        desktop_id=$(fuzzel --print-only "$@" 2>/dev/null || true)
        if [ -n "$desktop_id" ]; then
          exec gtk-launch "$desktop_id"
        fi
      fi
      exec fuzzel "$@"
      ;;
    dmenu)
      exec fuzzel --dmenu "$@"
      ;;
    *)
      echo "[ERROR] unknown menu mode: $mode" >&2
      exit 1
      ;;
  esac
fi

if have_cmd wofi; then
  case "$mode" in
    launcher)
      exec wofi --show drun --allow-images --insensitive --normal-window
      ;;
    dmenu)
      declare -a wofi_args=(--dmenu)
      while [ "$#" -gt 0 ]; do
        case "$1" in
          --config)
            shift 2 || true
            ;;
          --lines)
            if [ "$#" -ge 2 ]; then
              wofi_args+=("-L" "$2")
            fi
            shift 2 || true
            ;;
          -w)
            shift 2 || true
            ;;
          *)
            wofi_args+=("$1")
            shift
            ;;
        esac
      done
      exec wofi "${wofi_args[@]}"
      ;;
    *)
      echo "[ERROR] unknown menu mode: $mode" >&2
      exit 1
      ;;
  esac
fi

echo "[ERROR] no launcher found (tried: fuzzel, wofi)" >&2
exit 1
