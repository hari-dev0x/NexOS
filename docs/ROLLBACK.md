# Rollback & Recovery Guide

NexOS is engineered to be 100% reversible. Before making any modifications, the installer creates a timestamped snapshot of existing configurations.

## Automated Uninstallation & Rollback
Run the uninstaller script:
```bash
./uninstall.sh
```
The uninstaller will:
1. Delete NexOS-managed directories:
   - `~/.config/quickshell/sea-shell`
   - `~/.config/sea-shell`
   - `~/.config/hypr/sea-shell`
2. Automatically locate the most recent backup snapshot in `~/.config/nexos-backups/checkpoint-*`.
3. Offer to restore your original configurations.

## Manual Restoration
If you wish to manually restore a specific checkpoint:
```bash
CHECKPOINT=$(ls -d ~/.config/nexos-backups/checkpoint-* | tail -n 1)

# Restore Hyprland:
cp -a "$CHECKPOINT/hypr/"* ~/.config/hypr/

# Restore Quickshell:
cp -a "$CHECKPOINT/quickshell/"* ~/.config/quickshell/
```
