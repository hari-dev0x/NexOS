#!/usr/bin/env bash
# ==============================================================================
# NexOS Hardware Boot & Login Theme Installer (Optional)
# Installs Plymouth boot splash and SDDM greeter themes into system directories.
# Requires root privileges (pkexec or sudo).
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PLYMOUTH_SRC="${REPO_ROOT}/config/boot/plymouth"
SDDM_SRC="${REPO_ROOT}/config/boot/sddm"
QUIT_SCRIPT="${REPO_ROOT}/config/boot/nexos-plymouth-quit.sh"

PLYMOUTH_DEST="/usr/share/plymouth/themes/nexos"
SDDM_DEST="/usr/share/sddm/themes/nexos"
SYSTEM_BIN="/usr/local/bin/nexos-plymouth-quit.sh"

BACKUP_DIR="/var/backups/nexos-boot-backup-$(date +%Y%m%d-%H%M%S)"

# Privilege check
if [ "$EUID" -ne 0 ]; then
    echo "Root privileges required for system theme installation."
    if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ] && command -v pkexec &>/dev/null; then
        exec pkexec "$0" "$@"
    elif command -v sudo &>/dev/null; then
        exec sudo "$0" "$@"
    else
        echo "Error: Neither pkexec nor sudo available to elevate privileges." >&2
        exit 1
    fi
fi

install_boot() {
    echo "=========================================================="
    echo " NexOS Hardware Boot & Login Sequence Installer"
    echo "=========================================================="

    mkdir -p "${BACKUP_DIR}"

    # 1. Plymouth theme
    if [ -d "${PLYMOUTH_SRC}" ] && [ -f "${PLYMOUTH_SRC}/nexos.plymouth" ]; then
        echo "Deploying Plymouth theme to ${PLYMOUTH_DEST}..."
        if [ -d "${PLYMOUTH_DEST}" ]; then
            cp -a "${PLYMOUTH_DEST}" "${BACKUP_DIR}/plymouth-previous"
        fi
        mkdir -p "${PLYMOUTH_DEST}"
        cp -r "${PLYMOUTH_SRC}/"* "${PLYMOUTH_DEST}/"

        if command -v plymouth-set-default-theme &>/dev/null; then
            echo "Setting default Plymouth theme to nexos..."
            plymouth-set-default-theme -R nexos || true
        fi
    fi

    # 2. SDDM theme
    if [ -d "${SDDM_SRC}" ] && [ -f "${SDDM_SRC}/Main.qml" ]; then
        echo "Deploying SDDM greeter theme to ${SDDM_DEST}..."
        if [ -d "${SDDM_DEST}" ]; then
            cp -a "${SDDM_DEST}" "${BACKUP_DIR}/sddm-previous"
        fi
        mkdir -p "${SDDM_DEST}"
        cp -r "${SDDM_SRC}/"* "${SDDM_DEST}/"

        # Configure SDDM theme in /etc/sddm.conf.d/ if sddm is installed
        if [ -d "/etc/sddm.conf.d" ]; then
            echo "[Theme]" > "/etc/sddm.conf.d/10-nexos-theme.conf"
            echo "Current=nexos" >> "/etc/sddm.conf.d/10-nexos-theme.conf"
        fi
    fi

    # 3. Synchronizer script
    if [ -f "${QUIT_SCRIPT}" ]; then
        echo "Installing plymouth quit synchronizer to ${SYSTEM_BIN}..."
        install -m 755 "${QUIT_SCRIPT}" "${SYSTEM_BIN}"
    fi

    echo "Boot and login themes installed successfully."
    echo "System backup stored in: ${BACKUP_DIR}"
}

install_boot
