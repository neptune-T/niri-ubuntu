#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"

app="${1:-}"
if [ -z "$app" ]; then
  echo "[ERROR] usage: launch-desktop-entry.sh <desktop-id-or-command>" >&2
  exit 1
fi

if have_cmd gtk-launch; then
  case "$app" in
    code|code.desktop) exec gtk-launch code ;;
    cursor|cursor.desktop) exec gtk-launch cursor ;;
    google-chrome|google-chrome.desktop|com.google.Chrome.desktop) exec gtk-launch google-chrome ;;
    firefox|firefox.desktop) exec gtk-launch firefox ;;
    wechat|wechat.desktop) exec gtk-launch wechat ;;
    qq|qq.desktop) exec gtk-launch qq ;;
    clash|clash-nyanpasu.desktop) exec gtk-launch clash-nyanpasu ;;
  esac
fi

exec "$app"
