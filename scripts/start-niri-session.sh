#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=/dev/null
. "$SCRIPT_DIR/common.sh"

ensure_niriconf

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
mkdir -p "$log_dir"
exec > >(tee -a "$log_dir/niri-session.log") 2>&1

echo "===== $(date '+%Y-%m-%d %H:%M:%S') starting niri session ====="
echo "HOME=$HOME"
echo "USER=${USER:-unknown}"

export NIRICONF
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export XDG_CURRENT_DESKTOP=niri
export XDG_SESSION_DESKTOP=niri
export XDG_SESSION_TYPE=wayland
export DESKTOP_SESSION=niri
export MOZ_ENABLE_WAYLAND=1
export NIXOS_OZONE_WL=1
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=gtk3
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export GDK_BACKEND=wayland,x11
unset DISPLAY
unset WAYLAND_DISPLAY

echo "PATH=$PATH"
echo "NIRICONF=$NIRICONF"
command -v niri || true
niri --version || true

exec niri --config "$NIRICONF/niri/config.kdl"
