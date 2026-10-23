#!/usr/bin/env bash
# ==============================================================================
# NexUI Safe Uninstaller & Rollback Assistant
# Removes NexUI-managed configurations and offers backup restoration.
# ==============================================================================
set -uo pipefail

CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_BASE="${CFG}/nexui-backups"
[[ -d "$BACKUP_BASE" ]] || BACKUP_BASE="${CFG}/nexos-backups"

# Formatting
c() { printf '\033[%sm' "$1"; }
info()  { printf '%s»%s %s\n' "$(c '38;2;118;169;250')" "$(c 0)" "$*"; }
ok()    { printf '%s✓%s %s\n' "$(c '38;2;52;211;153')" "$(c 0)" "$*"; }
warn()  { printf '%s!%s %s\n' "$(c '38;2;245;158;11')" "$(c 0)" "$*"; }
title() { printf '\n%s🔷 %s%s\n' "$(c '1;38;2;118;169;250')" "$*" "$(c 0)"; }

NON_INTERACTIVE=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes) NON_INTERACTIVE=1 ;;
    esac
done

title "NexUI Desktop Uninstaller"

cat << SUMMARY
The uninstaller will safely remove NexUI-managed desktop configurations:
  • ${CFG}/quickshell/sea-shell
  • ${CFG}/sea-shell
  • ${CFG}/hypr/sea-shell

Unrelated files, personal home directories, and user documents will NOT be touched.
SUMMARY

if [ "$NON_INTERACTIVE" -eq 0 ]; then
    printf '\nProceed with removing NexUI configurations? [y/N]: '
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) ;;
        *) info "Uninstallation cancelled."; exit 0 ;;
    esac
fi

# 1. Remove NexUI shell and hypr configs
if [ -d "${CFG}/quickshell/sea-shell" ]; then
    rm -rf "${CFG}/quickshell/sea-shell"
    ok "Removed ${CFG}/quickshell/sea-shell"
fi

if [ -d "${CFG}/sea-shell" ]; then
    rm -rf "${CFG}/sea-shell"
    ok "Removed ${CFG}/sea-shell"
fi

if [ -d "${CFG}/hypr/sea-shell" ]; then
    rm -rf "${CFG}/hypr/sea-shell"
    ok "Removed ${CFG}/hypr/sea-shell"
fi

# 2. Offer to restore latest backup
if [ -d "${BACKUP_BASE}" ]; then
    LATEST_BACKUP=$(find "${BACKUP_BASE}" -maxdepth 1 -name "checkpoint-*" -type d | sort | tail -n 1)
    if [ -n "${LATEST_BACKUP}" ] && [ -d "${LATEST_BACKUP}" ]; then
        info "Found backup checkpoint: ${LATEST_BACKUP}"
        if [ "$NON_INTERACTIVE" -eq 0 ]; then
            printf 'Restore this backup? [y/N]: '
            read -r restore_resp
            case "$restore_resp" in
                [yY][eE][sS]|[yY])
                    if [ -d "${LATEST_BACKUP}/hypr" ]; then
                        cp -a "${LATEST_BACKUP}/hypr/"* "${CFG}/hypr/" 2>/dev/null || true
                        ok "Restored hyprland configurations."
                    fi
                    if [ -d "${LATEST_BACKUP}/quickshell/sea-shell" ]; then
                        mkdir -p "${CFG}/quickshell/sea-shell"
                        cp -a "${LATEST_BACKUP}/quickshell/sea-shell/"* "${CFG}/quickshell/sea-shell/" 2>/dev/null || true
                        ok "Restored quickshell configurations."
                    fi
                    ;;
            esac
        fi
    fi
fi

ok "NexUI uninstallation complete."
