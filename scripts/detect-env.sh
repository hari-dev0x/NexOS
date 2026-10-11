#!/usr/bin/env bash
# ==============================================================================
# NexOS Environment Detector
# Inspects operating system, init/session, compositor, and package management.
# ==============================================================================
set -euo pipefail

detect_os() {
    local os_id=""
    local os_name=""
    local id_like=""

    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        os_id="${ID:-unknown}"
        os_name="${NAME:-Linux}"
        id_like="${ID_LIKE:-}"
    else
        os_id="unknown"
        os_name="Unknown Linux"
    fi

    echo "OS_ID=${os_id}"
    echo "OS_NAME=${os_name}"
    echo "ID_LIKE=${id_like}"
}

detect_session() {
    local session_type="${XDG_SESSION_TYPE:-}"
    local current_desktop="${XDG_CURRENT_DESKTOP:-}"
    local is_wayland=0
    local is_hyprland=0

    if [ "$session_type" = "wayland" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        is_wayland=1
    fi

    if [ "$current_desktop" = "Hyprland" ] || command -v hyprctl &>/dev/null; then
        is_hyprland=1
    fi

    echo "IS_WAYLAND=${is_wayland}"
    echo "IS_HYPRLAND=${is_hyprland}"
    echo "SESSION_TYPE=${session_type:-unknown}"
    echo "CURRENT_DESKTOP=${current_desktop:-unknown}"
}

detect_pkg_manager() {
    local pkg_mgr=""
    local aur_helper=""

    if command -v pacman &>/dev/null; then
        pkg_mgr="pacman"
        if command -v paru &>/dev/null; then
            aur_helper="paru"
        elif command -v yay &>/dev/null; then
            aur_helper="yay"
        fi
    elif command -v apt &>/dev/null; then
        pkg_mgr="apt"
    elif command -v dnf &>/dev/null; then
        pkg_mgr="dnf"
    elif command -v zypper &>/dev/null; then
        pkg_mgr="zypper"
    elif command -v nix-env &>/dev/null; then
        pkg_mgr="nix"
    fi

    echo "PKG_MGR=${pkg_mgr:-unknown}"
    echo "AUR_HELPER=${aur_helper:-none}"
}

main() {
    detect_os
    detect_session
    detect_pkg_manager
}

main "$@"
