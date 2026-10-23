#!/usr/bin/env bash
# ==============================================================================
# NexUI Installer — Clean, Reproducible Linux Desktop Installation
# Repository: https://github.com/hari-dev0x/NexOS
# License: GNU General Public License v3.0 (GPL-3.0)
# ==============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
VERSION="1.0.0"

# Defaults
DRY_RUN=0
NON_INTERACTIVE=0
SKIP_DEPS=0
INSTALL_BOOT=0

# Formatting
c() { printf '\033[%sm' "$1"; }
info()  { printf '%s»%s %s\n' "$(c '38;2;118;169;250')" "$(c 0)" "$*"; }
ok()    { printf '%s✓%s %s\n' "$(c '38;2;52;211;153')" "$(c 0)" "$*"; }
warn()  { printf '%s!%s %s\n' "$(c '38;2;245;158;11')" "$(c 0)" "$*"; }
err()   { printf '%s✗%s %s\n' "$(c '38;2;239;68;68')" "$(c 0)" "$*" >&2; }
title() { printf '\n%s🔷 %s%s\n' "$(c '1;38;2;118;169;250')" "$*" "$(c 0)"; }

usage() {
    cat << USAGE
NexUI Desktop Environment Installer v${VERSION}

Usage:
  ./install.sh [options]

Options:
  -y, --yes          Non-interactive mode (proceed without confirmation)
  --dry-run          Simulate actions without modifying files or installing packages
  --no-deps          Skip package manager dependency installation (configs only)
  --boot             Include optional Plymouth boot splash and SDDM login theme
  --uninstall        Safely remove NexUI-managed configurations
  -h, --help         Show this help message

Documentation & Verification:
  Clone & inspect first:
    git clone https://github.com/hari-dev0x/NexOS.git
    cd NexOS
    ./install.sh --dry-run
USAGE
}

# Parse options
while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes) NON_INTERACTIVE=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --no-deps) SKIP_DEPS=1 ;;
        --boot) INSTALL_BOOT=1 ;;
        --uninstall)
            exec "${SCRIPT_DIR}/uninstall.sh"
            ;;
        -h|--help) usage; exit 0 ;;
        *) warn "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

title "NexUI Desktop Environment Installer v${VERSION}"

# 1. Environment Detection
info "Detecting operating system and desktop environment..."
# shellcheck disable=SC1091
eval "$("${SCRIPT_DIR}/scripts/detect-env.sh")"

info "Operating System: ${OS_NAME} (${OS_ID})"
info "Session Type:     ${SESSION_TYPE}"
info "Desktop:          ${CURRENT_DESKTOP}"
info "Package Manager:  ${PKG_MGR} (AUR: ${AUR_HELPER})"

if [ "${OS_ID}" != "cachyos" ] && [ "${OS_ID}" != "arch" ] && [ "${ID_LIKE}" != "arch" ]; then
    warn "NexUI is optimized and verified for Arch Linux and CachyOS."
    warn "Running on an unverified distribution (${OS_NAME}). Proceeding in --no-deps configuration mode."
    SKIP_DEPS=1
fi

# 2. Dependency Inspection
title "Auditing System Dependencies"
"${SCRIPT_DIR}/scripts/check-deps.sh"

# 3. Installation Plan Summary
title "Planned Actions Summary"
cat << PLAN
  1. Configuration Backup: Snapshot existing ~/.config/hypr & ~/.config/quickshell
  2. Core Desktop Shell:   Deploy Hyprland configuration and Quickshell Sea-Shell UI
  3. UI Assets & Styling:  Configure Liquid Glass & ImpastoBar desktop components
  4. Script Permissions:   Grant executable rights (+x) to shell helpers
PLAN

if [ "$INSTALL_BOOT" -eq 1 ]; then
    echo "  5. Boot & Login Themes:  Deploy Plymouth theme & SDDM greeter (requires root)"
fi

if [ "$DRY_RUN" -eq 1 ]; then
    ok "Dry run enabled. No modifications were written to disk."
    exit 0
fi

# 4. Interactive Confirmation
if [ "$NON_INTERACTIVE" -eq 0 ]; then
    printf '\nProceed with NexUI installation? [y/N]: '
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) ;;
        *) info "Installation cancelled by user."; exit 0 ;;
    esac
fi

# 5. Package Installation (Arch/CachyOS)
if [ "$SKIP_DEPS" -eq 0 ]; then
    title "Installing Required Packages"
    PKGS=(
        hyprland kitty wl-clipboard cliphist matugen cava
        grim slurp swappy swaybg hypridle hyprlock
        brightnessctl playerctl wireplumber thunar
    )

    if [ "$PKG_MGR" = "pacman" ]; then
        info "Checking repository packages..."
        if [ "$AUR_HELPER" = "paru" ]; then
            paru -S --needed --noconfirm "${PKGS[@]}" quickshell-git || warn "Some packages may need manual installation."
        elif [ "$AUR_HELPER" = "yay" ]; then
            yay -S --needed --noconfirm "${PKGS[@]}" quickshell-git || warn "Some packages may need manual installation."
        else
            sudo pacman -S --needed --noconfirm "${PKGS[@]}" || warn "Please verify missing packages."
        fi
    fi
fi

# 6. Safe Configuration Backup
title "Creating Safety Backup"
"${SCRIPT_DIR}/scripts/backup.sh"

# 7. Configuration Deployment
title "Deploying NexUI Configurations"
"${SCRIPT_DIR}/scripts/install-configs.sh"

# 8. Optional Boot Themes
if [ "$INSTALL_BOOT" -eq 1 ]; then
    title "Deploying Boot & Login Themes"
    "${SCRIPT_DIR}/scripts/install-boot.sh"
fi

title "NexUI Installation Complete"
ok "Configurations deployed to ~/.config/hypr and ~/.config/quickshell/sea-shell."
info "To start or reload the NexUI environment:"
echo "  • In an existing Hyprland session: Press SUPER+SHIFT+B to reload the topbar, or hyprctl reload"
echo "  • From login: Select 'Hyprland' session in SDDM / display manager"
echo "  • To restore backups or remove: Run ./uninstall.sh"
