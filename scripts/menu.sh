#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

mode="${1:-launcher}"
shift || true

if have_cmd fuzzel; then
  case "$mode" in
    launcher)
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
      exec wofi --show drun
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
