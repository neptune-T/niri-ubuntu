#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

wallpaper_dir="$HOME/Pictures/wallpapers"
export GUM_CHOOSE_HEADER_FOREGROUND="#d8dadd"
export GUM_CHOOSE_SELECTED_FOREGROUND="#758A9B"
export GUM_CHOOSE_CURSOR_FOREGROUND="#758A9B"

missing=()
for dep in gum imagemagick swaybg swww; do
  have_cmd "$dep" || missing+=("$dep")
done

if ! first_cmd fd fdfind >/dev/null 2>&1; then
  missing+=("fd/fdfind")
fi

if [ "${#missing[@]}" -gt 0 ]; then
  echo "[ERROR] missing dependencies: ${missing[*]}"
  exit 1
fi

mkdir -p "$wallpaper_dir"

fd_cmd=$(first_cmd fd fdfind)
images=$("$fd_cmd" . --base-directory "$wallpaper_dir" --type f | grep -E '\.(jpg|jpeg|png|webp)$' | sort || true)
if [ -z "$images" ]; then
  echo "[ERROR] no image file found"
  echo "[INFO] place your wallpapers in $wallpaper_dir"
  read -n 1 -s -r -p "[INFO] Press any key to finish..."
  exit 1
fi

image="$wallpaper_dir/$(echo "$images" | gum choose --header 'Choose your wallpaper: ')"
mode=$(echo -e "stretch\nfill\nfit\ncenter\ntile" | gum choose --header "Choose wallpaper mode: ")

if [ -z "$image" ] || [ -z "$mode" ]; then
  exit 1
fi

workspace_target="$NIRICONF/wallpapers/workspace.${image##*.}"
backdrop_target="$NIRICONF/wallpapers/backdrop.${image##*.}"

echo "[INFO] New wallpaper: $image"
echo "[INFO] Copying new wallpaper to $NIRICONF..."
cp -f "$image" "$workspace_target"

canvas_color=$(magick "$workspace_target" -crop x1+0+0 -resize 1x1 txt:- | grep -o '#[0-9A-Fa-f]\{6\}' | head -n 1)
workspace_cmd="swaybg -i $workspace_target -m $mode -c '$canvas_color'"
escaped_workspace_cmd=${workspace_cmd//&/\\&}
sed -i "s|^spawn-sh-at-startup \"swaybg.*|spawn-sh-at-startup \"$escaped_workspace_cmd\"|" "$NIRICONF/niri/wallpapers.kdl"
pkill swaybg || true
nohup sh -c "$workspace_cmd" >/dev/null 2>&1 &

echo "[INFO] Creating new overview backdrop..."
magick "$workspace_target" -scale 10% -blur 0x2.5 -resize 1000% "$backdrop_target"
backdrop_cmd="swww-daemon & swww img $backdrop_target"
escaped_backdrop_cmd=${backdrop_cmd//&/\\&}
if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  nohup swww-daemon >/dev/null 2>&1 &
  sleep 1
fi
swww img "$backdrop_target" >/dev/null 2>&1 || true
sed -i "s|^spawn-sh-at-startup \"swww-daemon.*img.*|spawn-sh-at-startup \"$escaped_backdrop_cmd\"|" "$NIRICONF/niri/wallpapers.kdl"

echo "[INFO] Done!"
read -n 1 -s -r -p "[INFO] Press any key to finish..."
