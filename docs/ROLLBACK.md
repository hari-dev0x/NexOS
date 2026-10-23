# Rollback & Recovery Guide

**NexUI** is engineered to be 100% reversible. Before making any modifications, the installer creates a timestamped snapshot of existing configurations.

---

## 1. Automated Uninstallation & Rollback

Run the unified uninstaller script:

```bash
./uninstall.sh
```

The uninstaller will:
1. Stop the user service: `systemctl --user stop nexui.service`
2. Remove NexUI deployment directories and symlinks:
   - `~/.config/quickshell/reimagined`
   - `~/.config/systemd/user/nexui.service`
   - `~/.local/bin/nexui`
3. Automatically locate the most recent backup snapshot in `~/.config/nexui-backups/` or `~/.config/nexos-backups/`.
4. Offer to restore your original desktop configuration.

---

## 2. Manual Restoration from Checkpoint

If you prefer to manually inspect and restore a specific backup snapshot:

```bash
# Locate available snapshots
ls -la ~/.config/nexui-backups/

# Select the desired checkpoint
CHECKPOINT=$(ls -d ~/.config/nexui-backups/checkpoint-* 2>/dev/null | tail -n 1)

# Restore Niri configurations:
[ -d "$CHECKPOINT/niri" ] && cp -a "$CHECKPOINT/niri/"* ~/.config/niri/

# Restore Quickshell configurations:
[ -d "$CHECKPOINT/quickshell" ] && cp -a "$CHECKPOINT/quickshell/"* ~/.config/quickshell/

# Reload compositor
niri msg action reload-config
```
