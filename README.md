# kevin-fetch

**Kevin is a cat** and **kevin-fetch** is a  lightweight and customizable system information tool for Linux, written in Bash. It displays various system details like CPU, GPU, memory, disk usage, and more, with optional ASCII art for your distribution. It is not advanced as some other info tools out there, since I this is my first fetch script.

---

## Features

- Detects and displays:
  - OS, host, kernel, uptime
  - CPU, GPU, memory, and disk usage
  - Display resolution
  - Desktop Environment (DE) and Window Manager (WM)
  - Package manager
- Custom ASCII art per distribution (can be extended via config)) (WILL BE SUPPORTED IN THE FUTURE)
- Configurable through a single `.conf` file
- Supports both simple and detailed disk usage modes
- Easy installation with symlink to `$HOME/bin/`

---

## Dependencies

Make sure the following tools are installed on your system:

- `bash`
- `lscpu`
- `lspci` (usually from `pciutils`)
- `free` (from `procps-ng`)
- `df`
- `awk`, `grep`, `sed`, `cut`, `tr`
- `xrandr` (for resolution detection)
- `xprop` (for WM detection)
- Optional for better DE support:
  - `plasmashell`, `gnome-shell`, etc.
  - `lookandfeeltool`, `gsettings`

---

## Instalation

- `git clone https://github.com/yourusername/kevin-fetch.git`
- `cd kevin-fetch`
-`run ./kevin-fetch.sh`

## Usage

Once installed, run it from your terminal:
`kevin-fetch`

---

## Configuration

You can enable or disable features by editing:
'~/.config/kevin-fetch/kevin-fetch.conf'

Example:
- SHOW_CPU_INFO=true
- SHOW_MEMORY_USAGE=true
- SHOW_DISK_USAGE=false



