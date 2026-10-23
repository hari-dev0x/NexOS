#!/usr/bin/env bash
# ==============================================================================
# NexUI Safe Backup Helper
# Creates a timestamped, non-destructive snapshot of user desktop configurations.
# ==============================================================================
set -euo pipefail

CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_BASE="${CFG}/nexui-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
CHECKPOINT_DIR="${BACKUP_BASE}/checkpoint-${TIMESTAMP}"

create_backup() {
    mkdir -p "${CHECKPOINT_DIR}"
    local count=0

    if [ -d "${CFG}/hypr" ]; then
        echo "Backing up ${CFG}/hypr..."
        cp -a "${CFG}/hypr" "${CHECKPOINT_DIR}/hypr"
        count=$((count + 1))
    fi

    if [ -d "${CFG}/quickshell/sea-shell" ]; then
        echo "Backing up ${CFG}/quickshell/sea-shell..."
        mkdir -p "${CHECKPOINT_DIR}/quickshell"
        cp -a "${CFG}/quickshell/sea-shell" "${CHECKPOINT_DIR}/quickshell/sea-shell"
        count=$((count + 1))
    fi

    if [ -d "${CFG}/sea-shell" ]; then
        echo "Backing up ${CFG}/sea-shell runtime state..."
        cp -a "${CFG}/sea-shell" "${CHECKPOINT_DIR}/sea-shell"
        count=$((count + 1))
    fi

    echo "BACKUP_DIR=${CHECKPOINT_DIR}"
    echo "BACKUP_ENTRIES=${count}"
    if [ "$count" -gt 0 ]; then
        echo "Backup successfully created at: ${CHECKPOINT_DIR}"
    else
        echo "No pre-existing NexUI configurations detected to back up."
    fi
}

create_backup
