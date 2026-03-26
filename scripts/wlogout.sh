#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$(realpath "$0")")/common.sh"
ensure_niriconf

wlogout -C "$NIRICONF/wlogout/style.css" -l "$NIRICONF/wlogout/layout" -b 5 -T 400 -B 400
