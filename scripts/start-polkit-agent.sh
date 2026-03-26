#!/usr/bin/env bash
set -euo pipefail

agents=(
  /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
  /usr/libexec/polkit-gnome-authentication-agent-1
  /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
)

for agent in "${agents[@]}"; do
  if [ -x "$agent" ]; then
    exec "$agent"
  fi
done

echo "[WARN] no polkit-gnome agent found" >&2
