#!/usr/bin/env bash

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

first_cmd() {
  local candidate
  for candidate in "$@"; do
    if have_cmd "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

resolve_niriconf() {
  if [ -n "${NIRICONF:-}" ] && [ -d "${NIRICONF}" ]; then
    printf '%s\n' "$NIRICONF"
    return 0
  fi

  local caller_path script_dir
  caller_path="${BASH_SOURCE[1]:-$0}"
  script_dir=$(cd -- "$(dirname -- "$caller_path")" && pwd)
  printf '%s\n' "$(cd -- "$script_dir/.." && pwd)"
}

ensure_niriconf() {
  export NIRICONF="${NIRICONF:-$(resolve_niriconf)}"
}

state_dir() {
  printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

idle_time_file() {
  printf '%s/idle-time\n' "$(state_dir)"
}

detect_package_manager() {
  if have_cmd pacman; then
    printf 'pacman\n'
    return 0
  fi

  if have_cmd apt-get; then
    printf 'apt\n'
    return 0
  fi

  printf 'unknown\n'
}
