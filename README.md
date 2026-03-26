# niri-setup

A polished [niri](https://github.com/YaLTeR/niri) desktop setup with Waybar, Fuzzel, Dunst, Swayidle, Swaylock, Wlogout, wallpaper switching, and a small set of helper scripts.

This repo now supports both:

- **Arch / Arch-based distros** via your preferred AUR helper
- **Ubuntu / Debian-based distros** via `apt`, with source-build fallbacks for packages that are missing from the distro repositories

## Included Components

- **Window manager:** [niri](https://github.com/YaLTeR/niri)
- **Launcher:** [Fuzzel](https://codeberg.org/dnkl/fuzzel)
- **Panel:** [Waybar](https://github.com/Alexays/Waybar)
- **Notifications:** [dunst](https://github.com/dunst-project/dunst)
- **Clipboard manager:** [cliphist](https://github.com/sentriz/cliphist)
- **Wallpaper tools:** [swaybg](https://github.com/swaywm/swaybg) + [swww](https://github.com/LGFae/swww)
- **Idle daemon:** [swayidle](https://github.com/swaywm/swayidle)
- **Lock screen:** [swaylock](https://github.com/swaywm/swaylock)
- **Logout menu:** [wlogout](https://github.com/ArtsyMacaw/wlogout)
- **Terminal:** [Alacritty](https://github.com/alacritty/alacritty)

## Recommended Extras

These are not fully managed by this repo, but the setup looks best with:

- **Fonts:** Ubuntu, Ubuntu Mono Nerd Font, JetBrains Mono Nerd Font, Noto Sans / Serif / Mono CJK
- **GTK theme:** [Colloid GTK Theme](https://github.com/vinceliuice/Colloid-gtk-theme)
- **Icon theme:** [Colloid Icon Theme](https://github.com/vinceliuice/Colloid-icon-theme)
- **Cursor:** [Adwaita](https://github.com/GNOME/adwaita-icon-theme)

## Screenshots

![screenshot1](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot1.png)
![screenshot2](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot2.png)
![screenshot3](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot3.png)
![screenshot4](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot4.png)
![screenshot5](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot5.png)
![screenshot6](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot6.png)
![screenshot7](https://raw.githubusercontent.com/acaibowlz/niri-setup/refs/heads/main/.github/assets/screenshots/screenshot7.png)

## Features

> [!NOTE]
> This configuration targets `niri v25.11`.

- Full desktop experience built around niri, Waybar, Fuzzel, Dunst, Swayidle, Swaylock, and Wlogout
- Waybar widgets and Fuzzel menus for idle timeout and power profiles
- Wallpaper picker that also regenerates the blurred overview backdrop
- Cross-distro update checker for both `pacman`- and `apt`-based systems
- Safer runtime fallbacks for audio control, terminal launching, Polkit agent startup, and Swaylock effects

## Installation

### Quick Start

```bash
git clone https://github.com/acaibowlz/niri-setup.git
cd niri-setup
./setup.sh
```

> [!IMPORTANT]
> Run `./setup.sh` as your normal user. Do **not** run `sudo ./setup.sh`. The script handles privileged package installation internally when needed.

### What `setup.sh` Does

The installer now matches the current codebase behavior:

- Detects whether the system uses `pacman` or `apt`
- Installs available runtime packages from the system package manager
- On Ubuntu / Debian, optionally builds missing tools from source into `~/.local/bin`
- Deploys this repo into `~/.local/share/niri-setup`
- Symlinks managed config directories into `~/.config`
- Backs up existing managed config paths before replacing them

### Supported Flows

- **Arch / Arch-based**
  - Uses `paru`, `yay`, `aura`, or `trizen`
  - Installs repo and AUR dependencies with your chosen helper

- **Ubuntu / Debian-based**
  - Uses `apt` for packages available in the distro repositories
  - Falls back to source builds for missing packages such as `niri`, `fuzzel`, `cliphist`, `swww`, `alacritty`, and `starship`
  - Automatically bootstraps a newer Rust stable toolchain with `rustup` when the distro `cargo` is too old for modern crates
  - Automatically bootstraps a newer Go toolchain when the distro `go` is too old for current `cliphist`
  - Installs extra native build dependencies needed by source builds, including packages such as `liblz4-dev`
  - Uses `wofi` as a launcher fallback when the distro is too old to build current `fuzzel`
  - Installs source-built binaries into `~/.local/bin`

> [!IMPORTANT]
> On Ubuntu 22.04, the first install can take a while because several required packages are not available in the default repositories and are built from source.

### Installer Options

```bash
./setup.sh --skip-install
./setup.sh --skip-build
```

- `--skip-install` deploys only the config files and skips package installation
- `--skip-build` is for Ubuntu / Debian users who want `apt` packages only and prefer to build missing tools manually

### Managed Paths

After installation, the repo is deployed to:

```text
~/.local/share/niri-setup
```

The installer then symlinks these managed directories into `~/.config`:

- `alacritty`
- `dunst`
- `fuzzel`
- `niri`
- `niriswitcher`
- `waybar`
- `wlogout`

## Runtime Compatibility Notes

Several scripts were adjusted to be distro-friendly:

- **Launcher fallback:** uses `fuzzel` when available, otherwise falls back to `wofi`
- **Terminal fallback:** tries `alacritty`, then `kitty`, `foot`, `gnome-terminal`, and `kgx`
- **Audio control fallback:** tries `pwvucontrol`, then `pavucontrol`
- **Polkit agent startup:** resolves common `polkit-gnome` installation paths
- **Lock screen:** uses `swaylock` everywhere, and only enables effect flags if the installed version supports them
- **Update widget:** supports both `pacman` and `apt`

## Ubuntu Notes

If you are using Ubuntu, keep these in mind:

- Running `./setup.sh` still needs `sudo` for `apt` operations
- Run `./setup.sh` directly as your normal user, then enter your password only when the script prompts for `sudo`
- Some parts may compile from source during the first run
- If you already installed the dependencies manually, `./setup.sh --skip-install` is the fastest way to deploy the config
- If source builds fail on your release, rerun with `./setup.sh --skip-build` and install the missing tools manually

## Dotfiles Not Included Here

For the rest of the author's dotfiles, refer to:

- [acaibowlz/dotfiles](https://github.com/acaibowlz/dotfiles)

Programs intentionally not managed by this repo include:

- `fastfetch`
- `fontconfig`
- `spicetify`
- `starship`
- `zsh`

## Keybindings

### Applications

| Keys                                                  | Action                    |
| :---------------------------------------------------- | :------------------------ |
| <kbd>Super</kbd> + <kbd>Enter</kbd>                   | Open terminal             |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Enter</kbd> | Open launcher             |
| <kbd>Super</kbd> + <kbd>B</kbd>                       | Open Firefox              |
| <kbd>Super</kbd> + <kbd>E</kbd>                       | Open Nautilus             |
| <kbd>Super</kbd> + <kbd>L</kbd>                       | Lock screen               |
| <kbd>Super</kbd> + <kbd>C</kbd>                       | Open clipboard menu       |
| <kbd>Super</kbd> + <kbd>I</kbd>                       | Change idle timeout       |
| <kbd>Super</kbd> + <kbd>P</kbd>                       | Change power profile      |
| <kbd>Super</kbd> + <kbd>U</kbd>                       | Open updater              |
| <kbd>Super</kbd> + <kbd>W</kbd>                       | Toggle Waybar             |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>W</kbd>     | Open wallpaper selector   |
| <kbd>Super</kbd> + <kbd>Backspace</kbd>               | Open logout menu          |

### Hardware / Media

| Keys                                                  | Action              |
| :---------------------------------------------------- | :------------------ |
| <kbd>XF86MonBrightnessUp</kbd>                        | Brightness +5%      |
| <kbd>XF86MonBrightnessDown</kbd>                      | Brightness -5%      |
| <kbd>XF86AudioRaiseVolume</kbd>                       | Volume +5%          |
| <kbd>XF86AudioLowerVolume</kbd>                       | Volume -5%          |
| <kbd>XF86AudioMute</kbd>                              | Toggle mute         |
| <kbd>XF86AudioPlay</kbd>                              | Play / pause        |
| <kbd>XF86AudioPause</kbd>                             | Pause               |
| <kbd>XF86AudioNext</kbd>                              | Next track          |
| <kbd>XF86AudioPrev</kbd>                              | Previous track      |

### Windows / Columns

| Keys                                                   | Action                                                  |
| :----------------------------------------------------- | :------------------------------------------------------ |
| <kbd>Super</kbd> + <kbd>Q</kbd>                        | Close window                                            |
| <kbd>Super</kbd> + <kbd>T</kbd>                        | Toggle floating                                         |
| <kbd>Super</kbd> + <kbd>M</kbd>                        | Maximize column                                         |
| <kbd>Super</kbd> + <kbd>F</kbd>                        | Fullscreen window                                       |
| <kbd>Super</kbd> + <kbd>Left</kbd>                     | Focus left column                                       |
| <kbd>Super</kbd> + <kbd>Right</kbd>                    | Focus right column                                      |
| <kbd>Super</kbd> + <kbd>Down</kbd>                     | Focus window below                                      |
| <kbd>Super</kbd> + <kbd>Up</kbd>                       | Focus window above                                      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Left</kbd>   | Move column left                                        |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Right</kbd>  | Move column right                                       |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Down</kbd>   | Move window down                                        |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Up</kbd>     | Move window up                                          |
| <kbd>Super</kbd> + <kbd>Home</kbd>                     | Focus first column                                      |
| <kbd>Super</kbd> + <kbd>End</kbd>                      | Focus last column                                       |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Home</kbd>   | Move column to first                                    |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>End</kbd>    | Move column to last                                     |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Left</kbd>  | Resize column width by -10%                             |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Right</kbd> | Resize column width by +10%                             |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Up</kbd>    | Resize window height by -10%                            |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Down</kbd>  | Resize window height by +10%                            |
| <kbd>Super</kbd> + <kbd>BracketLeft</kbd>              | Consume / expel window to the left column               |
| <kbd>Super</kbd> + <kbd>BracketRight</kbd>             | Consume / expel window to the right column              |
| <kbd>Super</kbd> + <kbd>Comma</kbd>                    | Consume window into the focused column                  |
| <kbd>Super</kbd> + <kbd>Period</kbd>                   | Expel bottom window from focused column to the right    |
| <kbd>Alt</kbd> + <kbd>Tab</kbd>                        | Switch between recent windows                           |

### Workspaces

| Keys                                                     | Action                          |
| :------------------------------------------------------- | :------------------------------ |
| <kbd>Super</kbd> + <kbd>PageDown</kbd>                   | Focus workspace downward        |
| <kbd>Super</kbd> + <kbd>PageUp</kbd>                     | Focus workspace upward          |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>PageDown</kbd> | Move column to workspace below  |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>PageUp</kbd>   | Move column to workspace above  |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>1</kbd>        | Move column to workspace 1      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>2</kbd>        | Move column to workspace 2      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>3</kbd>        | Move column to workspace 3      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>4</kbd>        | Move column to workspace 4      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>5</kbd>        | Move column to workspace 5      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>6</kbd>        | Move column to workspace 6      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>7</kbd>        | Move column to workspace 7      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>8</kbd>        | Move column to workspace 8      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>9</kbd>        | Move column to workspace 9      |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>0</kbd>        | Move column to workspace 10     |
| <kbd>Super</kbd> + <kbd>A</kbd>                          | Toggle overview                 |

### Screenshots

| Keys                                | Action               |
| :---------------------------------- | :------------------- |
| <kbd>Print</kbd>                    | Screenshot region    |
| <kbd>Ctrl</kbd> + <kbd>Print</kbd>  | Screenshot window    |
| <kbd>Shift</kbd> + <kbd>Print</kbd> | Screenshot monitor   |
# niri-ubuntu
