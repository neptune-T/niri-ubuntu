#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=/dev/null
. "$SCRIPT_DIR/common.sh"

tty_name="$(tty 2>/dev/null || true)"

if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
  exit 0
fi

if [ "${XDG_VTNR:-}" != "1" ] && [ "$tty_name" != "/dev/tty1" ]; then
  exit 0
fi

if pgrep -u "$USER" -x niri >/dev/null 2>&1; then
  exit 0
fi

exec dbus-run-session "$SCRIPT_DIR/start-niri-session.sh"
