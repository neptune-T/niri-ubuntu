#!/usr/bin/env bash
set -euo pipefail

export GUM_CHOOSE_HEADER_FOREGROUND="#d8dadd"
export GUM_CHOOSE_SELECTED_FOREGROUND="#758A9B"
export GUM_CHOOSE_CURSOR_FOREGROUND="#758A9B"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/scripts/common.sh"

if [ "${EUID:-$(id -u)}" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
  echo "[ERROR] please run ./setup.sh as your normal user, not with sudo."
  echo "[INFO] the script will call sudo only for system package installation."
  exit 1
fi

SKIP_INSTALL=false
BUILD_MISSING=true

for arg in "$@"; do
  case "$arg" in
    --skip-install)
      SKIP_INSTALL=true
      ;;
    --skip-build)
      BUILD_MISSING=false
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ./setup.sh [options]

Options:
  --skip-install  Skip package installation and only deploy config files.
  --skip-build    On Ubuntu/Debian, do not build missing packages from source.
  -h, --help      Show this help text.
EOF
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $arg"
      exit 1
      ;;
  esac
done

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
INSTALL_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/niri-setup"
BUILD_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/niri-setup"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
APT_SOURCES_FILE=""
RUST_MIN_VERSION="1.85.0"
GO_MIN_VERSION="1.20.0"
GO_TOOLCHAIN_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/niri-setup-toolchains"
declare -a CARGO_CMD=(cargo)
declare -a GO_CMD=(go)

run_as_root() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

apt_cache_policy() {
  if [ -n "$APT_SOURCES_FILE" ]; then
    LC_ALL=C apt-cache \
      -o Dir::Etc::sourcelist="$APT_SOURCES_FILE" \
      -o Dir::Etc::sourceparts="-" \
      policy "$1"
  else
    LC_ALL=C apt-cache policy "$1"
  fi
}

apt_get() {
  if [ -n "$APT_SOURCES_FILE" ]; then
    run_as_root apt-get \
      -o Dir::Etc::sourcelist="$APT_SOURCES_FILE" \
      -o Dir::Etc::sourceparts="-" \
      "$@"
  else
    run_as_root apt-get "$@"
  fi
}

make_fallback_apt_sources() {
  mkdir -p "$BUILD_ROOT"

  local fallback_file="$BUILD_ROOT/ubuntu-official.sources.list"
  local primary_mirror
  local security_mirror

  . /etc/os-release

  primary_mirror=$(awk -v suite="$VERSION_CODENAME" '
    $1 == "deb" && $3 == suite && $2 ~ /ubuntu\/?$/ {
      print $2
      exit
    }
  ' /etc/apt/sources.list 2>/dev/null)
  security_mirror=$(awk '
    $1 == "deb" && $2 ~ /security\.ubuntu\.com\/ubuntu\/?$/ {
      print $2
      exit
    }
  ' /etc/apt/sources.list 2>/dev/null)

  primary_mirror=${primary_mirror:-http://archive.ubuntu.com/ubuntu/}
  security_mirror=${security_mirror:-http://security.ubuntu.com/ubuntu}

  cat >"$fallback_file" <<EOF
deb $primary_mirror $VERSION_CODENAME main restricted universe multiverse
deb $primary_mirror ${VERSION_CODENAME}-updates main restricted universe multiverse
deb $primary_mirror ${VERSION_CODENAME}-backports main restricted universe multiverse
deb $security_mirror ${VERSION_CODENAME}-security main restricted universe multiverse
EOF

  printf '%s\n' "$fallback_file"
}

refresh_apt_indexes() {
  if apt_get update; then
    return 0
  fi

  echo "[WARN] apt update failed with the full source list."
  echo "[WARN] retrying with official Ubuntu repositories only..."
  APT_SOURCES_FILE=$(make_fallback_apt_sources)
  apt_get update
}

apt_has_candidate() {
  local package="$1"
  local candidate
  candidate=$(apt_cache_policy "$package" 2>/dev/null | awk '/Candidate:/ { print $2 }')
  [ -n "$candidate" ] && [ "$candidate" != "(none)" ]
}

version_gte() {
  local current="$1"
  local required="$2"

  [ -n "$current" ] && [ -n "$required" ] || return 1
  [ "$(printf '%s\n%s\n' "$required" "$current" | sort -V | head -n 1)" = "$required" ]
}

cargo_version() {
  if ! have_cmd cargo; then
    return 1
  fi

  cargo --version 2>/dev/null | awk '{ print $2 }'
}

go_version() {
  if ! have_cmd go; then
    return 1
  fi

  go version 2>/dev/null | awk '{ print $3 }' | sed 's/^go//'
}

go_platform_arch() {
  case "$(uname -m)" in
    x86_64|amd64)
      printf 'amd64\n'
      ;;
    aarch64|arm64)
      printf 'arm64\n'
      ;;
    armv6l)
      printf 'armv6l\n'
      ;;
    *)
      echo "[ERROR] unsupported architecture for automatic Go bootstrap: $(uname -m)"
      exit 1
      ;;
  esac
}

install_go_toolchain() {
  local go_version_tag
  local arch
  local archive
  local url
  local temp_dir

  echo "[INFO] installing a newer Go toolchain..."

  if have_cmd curl; then
    go_version_tag=$(curl -fsSL https://go.dev/VERSION?m=text | head -n 1)
  elif have_cmd wget; then
    go_version_tag=$(wget -qO- https://go.dev/VERSION?m=text | head -n 1)
  else
    echo "[ERROR] Go bootstrap requires curl or wget"
    exit 1
  fi

  if [ -z "$go_version_tag" ]; then
    echo "[ERROR] failed to determine the latest Go release"
    exit 1
  fi

  arch=$(go_platform_arch)
  archive="${go_version_tag}.linux-${arch}.tar.gz"
  url="https://go.dev/dl/${archive}"
  temp_dir=$(mktemp -d)

  mkdir -p "$GO_TOOLCHAIN_ROOT"

  if have_cmd curl; then
    curl -fL "$url" -o "$temp_dir/$archive"
  else
    wget -O "$temp_dir/$archive" "$url"
  fi

  rm -rf "$GO_TOOLCHAIN_ROOT/go"
  tar -C "$GO_TOOLCHAIN_ROOT" -xzf "$temp_dir/$archive"
  rm -rf "$temp_dir"

  export PATH="$GO_TOOLCHAIN_ROOT/go/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
}

ensure_modern_go_toolchain() {
  local system_go_version=""

  if have_cmd go; then
    system_go_version=$(go_version || true)
    if version_gte "$system_go_version" "$GO_MIN_VERSION"; then
      GO_CMD=(go)
      return 0
    fi
  fi

  echo "[WARN] go ${system_go_version:-missing} is too old for current cliphist releases."
  install_go_toolchain

  local installed_go_version
  installed_go_version=$("$GO_TOOLCHAIN_ROOT/go/bin/go" version | awk '{ print $3 }' | sed 's/^go//')
  if ! version_gte "$installed_go_version" "$GO_MIN_VERSION"; then
    echo "[ERROR] bootstrapped Go is still too old: $installed_go_version"
    exit 1
  fi

  GO_CMD=("$GO_TOOLCHAIN_ROOT/go/bin/go")
}

install_rustup() {
  echo "[INFO] installing rustup to get a newer Rust toolchain..."

  if have_cmd curl; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable --no-modify-path
  elif have_cmd wget; then
    wget -qO- https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable --no-modify-path
  else
    echo "[ERROR] rustup bootstrap requires curl or wget"
    exit 1
  fi

  export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

  if have_cmd rustup; then
    rustup set auto-self-update disable >/dev/null 2>&1 || true
  fi
}

ensure_modern_rust_toolchain() {
  local system_cargo_version=""

  if have_cmd cargo; then
    system_cargo_version=$(cargo_version || true)
    if version_gte "$system_cargo_version" "$RUST_MIN_VERSION"; then
      CARGO_CMD=(cargo)
      return 0
    fi
  fi

  if ! have_cmd rustup; then
    echo "[WARN] cargo ${system_cargo_version:-missing} is too old for edition2024 crates."
    install_rustup
  fi

  echo "[INFO] ensuring Rust stable toolchain >= $RUST_MIN_VERSION..."
  rustup set auto-self-update disable >/dev/null 2>&1 || true
  rustup toolchain install stable --profile minimal --no-self-update

  local stable_cargo_version
  stable_cargo_version=$(rustup run stable cargo --version | awk '{ print $2 }')
  if ! version_gte "$stable_cargo_version" "$RUST_MIN_VERSION"; then
    echo "[ERROR] rustup stable cargo is still too old: $stable_cargo_version"
    exit 1
  fi

  CARGO_CMD=(rustup run stable cargo)
}

backup_path() {
  local path="$1"

  if [ -L "$path" ] || [ -e "$path" ]; then
    local backup="${path}.backup.${TIMESTAMP}"
    mv "$path" "$backup"
    echo "[INFO] backed up $path -> $backup"
  fi
}

link_config_dir() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$(dirname "$target_dir")"

  if [ -L "$target_dir" ] && [ "$(readlink -f "$target_dir")" = "$(readlink -f "$source_dir")" ]; then
    return 0
  fi

  backup_path "$target_dir"
  ln -s "$source_dir" "$target_dir"
}

replace_placeholders() {
  local base_dir="$1"
  local files=(
    "$base_dir/niri/binds.kdl"
    "$base_dir/niri/spawn-at-startup.kdl"
    "$base_dir/niri/wallpapers.kdl"
    "$base_dir/waybar/config"
    "$base_dir/waybar/modules.jsonc"
    "$base_dir/wlogout/layout"
  )

  local file
  for file in "${files[@]}"; do
    sed -i "s|\$NIRICONF|$INSTALL_ROOT|g" "$file"
  done
}

deploy_files() {
  local stage_dir
  stage_dir=$(mktemp -d)

  local entries=(
    alacritty
    dunst
    fuzzel
    niri
    niriswitcher
    scripts
    wallpapers
    waybar
    wlogout
  )

  local entry
  for entry in "${entries[@]}"; do
    cp -a "$SCRIPT_DIR/$entry" "$stage_dir/"
  done

  replace_placeholders "$stage_dir"

  mkdir -p "$(dirname "$INSTALL_ROOT")"
  if [ -e "$INSTALL_ROOT" ] || [ -L "$INSTALL_ROOT" ]; then
    backup_path "$INSTALL_ROOT"
  fi
  mv "$stage_dir" "$INSTALL_ROOT"

  local config_dirs=(
    alacritty
    dunst
    fuzzel
    niri
    niriswitcher
    waybar
    wlogout
  )

  for entry in "${config_dirs[@]}"; do
    link_config_dir "$INSTALL_ROOT/$entry" "$HOME/.config/$entry"
  done
}

install_arch_packages() {
  local helper_options=(paru yay aura trizen)
  local available_helpers=()
  local helper
  for helper in "${helper_options[@]}"; do
    if have_cmd "$helper"; then
      available_helpers+=("$helper")
    fi
  done

  if [ "${#available_helpers[@]}" -eq 0 ]; then
    echo "[ERROR] no AUR helper available. please install one of {yay, paru, aura, trizen}."
    exit 1
  fi

  local aur="${available_helpers[0]}"
  if have_cmd gum; then
    aur=$(gum choose "${available_helpers[@]}" --header "choose an AUR helper:" --select-if-one)
  fi

  local pkgs=(
    alacritty
    brightnessctl
    cliphist
    dunst
    fd
    figlet
    firefox
    fuzzel
    imagemagick
    nautilus
    networkmanager
    niri
    niriswitcher
    pavucontrol
    playerctl
    power-profiles-daemon
    polkit-gnome
    starship
    swaybg
    swayidle
    swaylock-effects
    swww
    udiskie
    waybar
    wl-clipboard
    wlogout
    xwayland-satellite
  )

  "$aur" -Syu --needed "${pkgs[@]}"
}

install_apt_packages() {
  local runtime_packages=(
    brightnessctl
    dunst
    fd-find
    figlet
    imagemagick
    nautilus
    network-manager
    pavucontrol
    playerctl
    policykit-1-gnome
    power-profiles-daemon
    swaybg
    swayidle
    swaylock
    udiskie
    waybar
    wireplumber
    wl-clipboard
    wlogout
    xwayland
  )
  local build_packages=()
  local optional_packages=(
    gum
    alacritty
    cliphist
    fuzzel
    niri
    starship
    swww
    libdisplay-info-dev
  )
  local installable=()
  local missing=()
  local package

  refresh_apt_indexes

  if [ "$BUILD_MISSING" = true ]; then
    build_packages=(
      cargo
      curl
      git
      golang-go
      meson
      ninja-build
      pkg-config
      rustc
      scdoc
      wayland-protocols
      libcairo2-dev
      libdbus-1-dev
      libdrm-dev
      libegl-dev
      libfcft-dev
      libfontconfig1-dev
      libfreetype6-dev
      libgbm-dev
      libgdk-pixbuf-2.0-dev
      libinput-dev
      liblz4-dev
      libpam0g-dev
      libpango1.0-dev
      libpipewire-0.3-dev
      libpixman-1-dev
      libseat-dev
      libsystemd-dev
      libudev-dev
      libwayland-bin
      libwayland-dev
      libxcb-xfixes0-dev
      libxkbcommon-dev
    )
  fi

  for package in "${runtime_packages[@]}" "${build_packages[@]}" "${optional_packages[@]}"; do
    if apt_has_candidate "$package"; then
      installable+=("$package")
    else
      missing+=("$package")
    fi
  done

  apt_get install -y "${installable[@]}"

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "[WARN] apt packages not available on this Ubuntu release: ${missing[*]}"
  fi
}

install_cargo_package() {
  local command_name="$1"
  local package_name="$2"
  local repo_url="$3"

  if have_cmd "$command_name"; then
    return 0
  fi

  "${CARGO_CMD[@]}" install --locked --root "$HOME/.local" --git "$repo_url" "$package_name"
}

install_cliphist_from_source() {
  if have_cmd cliphist; then
    return 0
  fi

  ensure_modern_go_toolchain
  GOBIN="$HOME/.local/bin" "${GO_CMD[@]}" install go.senan.xyz/cliphist@latest
}

install_fuzzel_from_source() {
  if have_cmd fuzzel; then
    return 0
  fi

  local src_dir="$BUILD_ROOT/fuzzel"
  rm -rf "$src_dir"
  git clone --depth 1 https://codeberg.org/dnkl/fuzzel.git "$src_dir"
  meson setup "$src_dir/build" "$src_dir" --prefix "$HOME/.local"
  meson compile -C "$src_dir/build"
  meson install -C "$src_dir/build"
}

build_missing_ubuntu_packages() {
  mkdir -p "$BUILD_ROOT" "$HOME/.local/bin"

  if ! apt_has_candidate libdisplay-info-dev; then
    echo "[WARN] libdisplay-info-dev is unavailable on Ubuntu ${VERSION_ID:-unknown}; building niri from source may fail."
  fi

  ensure_modern_rust_toolchain

  install_cargo_package starship starship https://github.com/starship/starship.git
  install_cargo_package swww swww https://github.com/LGFae/swww.git
  install_cargo_package alacritty alacritty https://github.com/alacritty/alacritty.git
  install_cliphist_from_source
  install_fuzzel_from_source
  install_cargo_package niri niri https://github.com/YaLTeR/niri.git
}

main() {
  if [ "$SKIP_INSTALL" = false ]; then
    case "$(detect_package_manager)" in
      pacman)
        install_arch_packages
        ;;
      apt)
        . /etc/os-release
        install_apt_packages
        if [ "$BUILD_MISSING" = true ]; then
          build_missing_ubuntu_packages
        fi
        ;;
      *)
        echo "[ERROR] unsupported package manager"
        exit 1
        ;;
    esac
  fi

  deploy_files

  if have_cmd niri; then
    if niri validate >/dev/null 2>&1; then
      echo "[INFO] niri setup completed"
    else
      echo "[ERROR] niri validation failed:"
      niri validate
      exit 1
    fi
  else
    echo "[WARN] niri is not installed yet, skipped config validation"
  fi
}

main
