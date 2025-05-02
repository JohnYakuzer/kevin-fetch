#!/bin/bash

BIN_DIR="$HOME/bin"
if [[ ! "$PATH" =~ "$BIN_DIR" ]]; then
    echo "Dodajem $BIN_DIR u PATH..."
    echo "export PATH=\"$HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        source "$HOME/.zshrc"
    fi
fi

if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
fi

ln -sf "$(pwd)/kevin-fetch.sh" "$BIN_DIR/kevin-fetch"
chmod +x "$BIN_DIR/kevin-fetch"

CONFIG_FILE="$HOME/.config/kevin-fetch/kevin-fetch.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    touch "$CONFIG_FILE"
    echo "SHOW_ASCII_ART=true" >> "$CONFIG_FILE"
    echo "SHOW_CPU_INFO=true" >> "$CONFIG_FILE"
    echo "SHOW_GPU_INFO=true" >> "$CONFIG_FILE"
    echo "SHOW_MEMORY_USAGE=true" >> "$CONFIG_FILE"
    echo "SHOW_DISK_USAGE=true" >> "$CONFIG_FILE"
    echo "SIMPLE_DISK_USAGE=false" >> "$CONFIG_FILE"
    echo "SHOW_PARTITION_NAMES=true" >> "$CONFIG_FILE"
    echo "SHOW_ALL_PARTITIONS=false" >> "$CONFIG_FILE"
    echo "SHOW_WM_INFO=true" >> "$CONFIG_FILE"
    echo "SHOW_PACKAGE_MANAGER=true" >> "$CONFIG_FILE"
    echo "SHOW_RESOLUTION=true" >> "$CONFIG_FILE"
    echo "Config file created at $CONFIG_FILE"
fi

source "$CONFIG_FILE"

print_ascii_art() {
    if [[ "$SHOW_ASCII_ART" != "true" ]]; then return; fi
    ascii_file="$HOME/.config/kevin-fetch/ascii_arts.txt"
    [[ ! -f "$ascii_file" ]] && echo "ASCII file not found" && return
    os_name=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '"')
    match=$(awk -v osname="$os_name" '
        BEGIN {best=""}
        /^\[.*\]$/ {
            gsub(/^\[|\]$/, "", $0)
            if (tolower(osname) ~ tolower($0)) best = $0
        }
        END {print best}
    ' "$ascii_file")
    [[ -z "$match" ]] && match="Fallback"
    ascii_output=$(awk -v section="[$match]" '
        $0 == section {found=1; next}
        /^\[.*\]/ {if (found) exit; next}
        found {print}
    ' "$ascii_file")
    echo "$ascii_output"
}

get_cpu_info() {
    if [[ "$SHOW_CPU_INFO" != "true" ]]; then return; fi
    cpu_model=$(lscpu | grep "Model name:" | sed 's/Model name:[ \t]*//')
    cpu_cores=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    threads_per_core=$(lscpu | grep "Thread(s) per core:" | awk '{print $4}')
    total_threads=$((cpu_cores * threads_per_core))
    echo -e "CPU Info:  $cpu_model ($cpu_cores cores / $total_threads threads)"
}

get_gpu_info() {
    if [[ "$SHOW_GPU_INFO" != "true" ]]; then return; fi
    gpu_model=$(lspci | grep -i 'vga\|3d' | head -n1 | cut -d ':' -f3- | sed 's/^[ \t]*//')
    echo -e "GPU Info:  $gpu_model"
}

get_memory_usage() {
    if [[ "$SHOW_MEMORY_USAGE" != "true" ]]; then return; fi
    mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    echo "Memory Usage: $mem_used / $mem_total"
}

get_disk_usage() {
    if [[ "$SHOW_DISK_USAGE" != "true" ]]; then return; fi
    if [[ "$SIMPLE_DISK_USAGE" == "true" ]]; then
        percent=$(df -h / --output=pcent | tail -n1 | tr -d ' ')
        echo "Disk Usage: $percent used on /"
        return
    fi
    echo -e "Disk Usage:"
    printf "  %-20s %-8s %-8s\n" \
        "$( [[ "$SHOW_PARTITION_NAMES" == "true" ]] && echo "Mount" || echo "" )" \
        "Used" "Percent"
    df -h --output=target,used,pcent | grep -v "Mounted" | while read -r mount used percent; do
        if [[ "$SHOW_ALL_PARTITIONS" != "true" ]]; then
            [[ "$mount" != "/" && "$mount" != "/home" && "$mount" != "/boot" ]] && continue
        fi
        if [[ "$SHOW_PARTITION_NAMES" == "true" ]]; then
            printf "  %-20s %-8s %-8s\n" "$mount" "$used" "$percent"
        else
            printf "  %-8s %-8s\n" "$used" "$percent"
        fi
    done
}

get_de_version() {
    if command -v plasmashell &> /dev/null; then
        version=$(plasmashell --version 2>/dev/null)
        echo "DE: KDE Plasma"
        echo "DE Version: $version"
    elif command -v gnome-shell &> /dev/null; then
        version=$(gnome-shell --version 2>/dev/null)
        echo "DE: GNOME"
        echo "DE Version: $version"
    elif command -v xfce4-session &> /dev/null; then
        version=$(xfce4-session --version 2>/dev/null)
        echo "DE: XFCE"
        echo "DE Version: $version"
    elif command -v lxqt-session &> /dev/null; then
        version=$(lxqt-session --version 2>/dev/null)
        echo "DE: LXQt"
        echo "DE Version: $version"
    elif command -v cinnamon &> /dev/null; then
        version=$(cinnamon --version 2>/dev/null)
        echo "DE: Cinnamon"
        echo "DE Version: $version"
    elif command -v mate-session &> /dev/null; then
        version=$(mate-session --version 2>/dev/null)
        echo "DE: MATE"
        echo "DE Version: $version"
    elif command -v unity-control-center &> /dev/null; then
        version=$(unity-control-center --version 2>/dev/null)
        echo "DE: Unity"
        echo "DE Version: $version"
    elif command -v budgie-panel &> /dev/null; then
        version=$(budgie-panel --version 2>/dev/null)
        echo "DE: Budgie"
        echo "DE Version: $version"
    elif command -v cosmic-shell &> /dev/null; then
        version=$(cosmic-shell --version 2>/dev/null)
        echo "DE: Cosmic"
        echo "DE Version: $version"
    else
        echo "DE: Unknown"
    fi
}

get_window_manager() {
    if [[ "$SHOW_WM_INFO" != "true" ]]; then return; fi
    wm=$(xprop -root _NET_SUPPORTING_WM_CHECK 2>/dev/null |
         awk -F'# ' '{print $2}' |
         xargs -I {} xprop -id {} _NET_WM_NAME 2>/dev/null |
         cut -d'"' -f2)
    echo "WM: ${wm:-Unknown}"
}

get_package_manager() {
    if [[ "$SHOW_PACKAGE_MANAGER" != "true" ]]; then return; fi
    if command -v pacman &>/dev/null; then
        echo "Package Manager: pacman"
    elif command -v apt &>/dev/null; then
        echo "Package Manager: apt"
    elif command -v dnf &>/dev/null; then
        echo "Package Manager: dnf"
    elif command -v zypper &>/dev/null; then
        echo "Package Manager: zypper"
    else
        echo "Package Manager: Unknown"
    fi
}

get_resolution() {
    if [[ "$SHOW_RESOLUTION" != "true" ]]; then return; fi
    resolutions=$(xrandr | grep '*' | awk '{print $1}')
    echo "Resolution: $resolutions"
}

clear

print_ascii_art
echo ""
echo -e "Username: $USER"
echo -e "OS: $(uname -s) $(uname -r)"
echo -e "Host: $(hostname)"
echo -e "Kernel: $(uname -r)"
echo -e "Uptime: $(uptime -p)"
get_package_manager
echo -e "Shell: $SHELL"
get_resolution
get_de_version
get_window_manager
echo "Theme: $(lookandfeeltool -l 2>/dev/null | grep '^org.kde.breeze' || echo 'Unknown')"
echo "Icons: $(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo 'Unknown')"
echo "Terminal: $TERM"
get_cpu_info
get_gpu_info
get_memory_usage
get_disk_usage
