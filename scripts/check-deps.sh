#!/usr/bin/env bash
# ==============================================================================
# NexOS Dependency Checker
# Identifies installed vs missing packages across core, shell, and media tools.
# ==============================================================================
set -euo pipefail

CORE_COMMANDS=(
    "hyprland:Hyprland Compositor"
    "qs:Quickshell UI Engine"
    "kitty:Terminal Emulator"
    "wl-copy:Wayland Clipboard (wl-clipboard)"
    "cliphist:Clipboard History Manager"
    "thunar:File Manager"
)

SHELL_UTILITIES=(
    "matugen:Material Color Generator"
    "cava:Console Audio Visualizer"
    "grim:Wayland Screenshot Utility"
    "slurp:Region Selection Utility"
    "hyprlock:Screen Locker"
    "hypridle:Idle Management Daemon"
    "brightnessctl:Backlight Controller"
    "playerctl:MPRIS Media Controller"
    "wpctl:WirePlumber Audio Controller"
    "swaybg:Wallpaper Renderer"
    "gammastep:Night Light Controller"
)

OPTIONAL_EXTRAS=(
    "mpvpaper:Video Wallpaper Engine"
    "swappy:Interactive Screenshot Annotation"
    "foot:Secondary Terminal"
    "trash-empty:Trash Management Utility"
)

check_list() {
    local category="$1"
    shift
    local items=("$@")
    local missing=()
    local installed=()

    for entry in "${items[@]}"; do
        local cmd="${entry%%:*}"
        local desc="${entry##*:}"

        if command -v "$cmd" &>/dev/null; then
            installed+=("$cmd ($desc)")
        else
            missing+=("$cmd ($desc)")
        fi
    done

    echo "--- ${category} ---"
    echo "INSTALLED_COUNT=${#installed[@]}"
    echo "MISSING_COUNT=${#missing[@]}"

    if [ ${#missing[@]} -gt 0 ]; then
        echo "MISSING_ITEMS:"
        for m in "${missing[@]}"; do
            echo "  - $m"
        done
    fi
}

main() {
    echo "NEXOS_DEPENDENCY_AUDIT_START"
    check_list "Core Infrastructure" "${CORE_COMMANDS[@]}"
    check_list "Shell Components & Audio" "${SHELL_UTILITIES[@]}"
    check_list "Optional Extensions" "${OPTIONAL_EXTRAS[@]}"
    echo "NEXOS_DEPENDENCY_AUDIT_END"
}

main "$@"
