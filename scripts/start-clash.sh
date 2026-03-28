#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"

run_desktop() {
  local desktop_file="$1"
  if have_cmd gtk-launch && [ -f "/usr/share/applications/$desktop_file" ]; then
    exec gtk-launch "${desktop_file%.desktop}"
  fi
  return 1
}

if pgrep -u "${USER:-$(id -un)}" -f 'clash|nyanpasu|verge' >/dev/null 2>&1; then
  exit 0
fi

run_desktop "clash-nyanpasu.desktop"

if have_cmd clash-nyanpasu; then
  exec clash-nyanpasu
fi

if have_cmd clash-verge; then
  exec clash-verge
fi

if have_cmd clash-verge-rev; then
  exec clash-verge-rev
fi

echo "[ERROR] no supported Clash application found" >&2
exit 1
