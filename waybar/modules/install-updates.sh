#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/../../scripts/common.sh"

if have_cmd figlet; then
  figlet "Updates" -f slant -w 44 -c
  echo ""
  sleep 0.1
fi

case "$(detect_package_manager)" in
  pacman)
    if have_cmd paru; then
      paru -Syu
    elif have_cmd yay; then
      yay -Syu
    else
      sudo pacman -Syu
    fi
    ;;
  apt)
    sudo apt-get update
    sudo apt-get upgrade -y
    ;;
  *)
    echo "[ERROR] unsupported package manager"
    exit 1
    ;;
esac

echo ""
echo "[INFO] OK"
read -n 1 -s -r -p "[INFO] Press any key to finish..."
