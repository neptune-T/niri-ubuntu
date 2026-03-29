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

# Ubuntu Snap support
if [ -d "/snap/bin" ]; then
  export PATH="/snap/bin:$PATH"
fi

# Set up XDG_DATA_DIRS to include snap and flatpak application directories
# so that fuzzel/gtk-launch can find .desktop entries for those apps
_xdg_data_base="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
if [ -d "/var/lib/snapd/desktop" ]; then
  _xdg_data_base="/var/lib/snapd/desktop:$_xdg_data_base"
fi
if [ -d "/var/lib/flatpak/exports/share" ]; then
  _xdg_data_base="/var/lib/flatpak/exports/share:$_xdg_data_base"
fi
if [ -d "$HOME/.local/share/flatpak/exports/share" ]; then
  _xdg_data_base="$HOME/.local/share/flatpak/exports/share:$_xdg_data_base"
fi
export XDG_DATA_DIRS="$_xdg_data_base"
unset _xdg_data_base

# Input method environment variables
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# (these are overridden below if only ibus is found)
if ! command -v fcitx5 >/dev/null 2>&1 && command -v ibus >/dev/null 2>&1; then
  export GTK_IM_MODULE=ibus
  export QT_IM_MODULE=ibus
  export XMODIFIERS=@im=ibus
fi

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
