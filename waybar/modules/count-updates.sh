#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/../../scripts/common.sh"

updates=0

case "$(detect_package_manager)" in
  pacman)
    updates_pacman=0
    updates_aur=0

    if have_cmd checkupdates; then
      updates_pacman=$(checkupdates 2>/dev/null | wc -l)
    fi

    if have_cmd paru; then
      updates_aur=$(paru -Qua 2>/dev/null | grep -v "\[ignored\]" | wc -l)
    elif have_cmd yay; then
      updates_aur=$(yay -Qua 2>/dev/null | grep -v "\[ignored\]" | wc -l)
    fi

    updates=$((updates_pacman + updates_aur))
    ;;
  apt)
    updates=$(apt list --upgradable 2>/dev/null | awk 'NR > 1 { count++ } END { print count + 0 }')
    ;;
  *)
    updates="?"
    ;;
esac

printf '{"text": "%s", "alt": "%s", "tooltip": "%s updates"}' "$updates" "$updates" "$updates"
