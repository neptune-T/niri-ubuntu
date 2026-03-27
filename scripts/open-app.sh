#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"

app="${1:-}"

if [ -z "$app" ]; then
  echo "[ERROR] usage: open-app.sh <app>" >&2
  exit 1
fi

run_first() {
  local candidate
  for candidate in "$@"; do
    if have_cmd "$candidate"; then
      exec "$candidate"
    fi
  done
  return 1
}

case "$app" in
  vscode|code)
    run_first code code-insiders codium cursor
    ;;
  wechat)
    run_first wechat uos-wechat linuxqq
    ;;
  google|chrome|browser)
    run_first google-chrome-stable google-chrome microsoft-edge-stable chromium chromium-browser firefox
    ;;
  *)
    echo "[ERROR] unsupported app alias: $app" >&2
    exit 1
    ;;
esac

echo "[ERROR] no installed command found for app alias: $app" >&2
exit 1
