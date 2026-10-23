#!/usr/bin/env bash
# ==============================================================================
# NexUI User Configuration Installer
# Installs portable, reviewed configuration trees into ~/.config
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_CFG="${REPO_ROOT}/config"

CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
HYPR_TARGET="${CFG}/hypr"
QS_TARGET="${CFG}/quickshell/sea-shell"
DATA_TARGET="${CFG}/sea-shell"

install_user_configs() {
    echo "Installing NexUI desktop configuration trees..."

    # 1. Target directories
    mkdir -p "${HYPR_TARGET}" "${QS_TARGET}" "${DATA_TARGET}"

    # 2. Hyprland configuration
    echo "Deploying Hyprland configuration into ${HYPR_TARGET}..."
    cp -r "${SOURCE_CFG}/hypr/"* "${HYPR_TARGET}/"

    # 3. Quickshell shell configuration
    echo "Deploying Quickshell sea-shell into ${QS_TARGET}..."
    cp -r "${SOURCE_CFG}/quickshell/sea-shell/"* "${QS_TARGET}/"

    # 4. Set execution permissions on shell & python scripts
    echo "Configuring executable permissions on shell helpers..."
    find "${QS_TARGET}" -maxdepth 2 -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +

    # 5. Initialize runtime directory marker if needed
    touch "${QS_TARGET}/.sea-shell"

    echo "User configuration installation complete."
}

install_user_configs
