# ii-pixel-sddm (Staged SDDM Theme)

This directory contains the official **iNiR ii-pixel-sddm** theme and its installer script.

> [!IMPORTANT]
> **Safety Notice**: This theme is staged for manual review and is **NOT** automatically enabled or applied during shell startup. Changing display managers or SDDM greeters can interrupt active login sessions or break existing display manager configurations.

## Contents

- `Main.qml`, `ClassicLogin.qml`, `LoginFrame.qml`, etc. — Complete SDDM QML login interface.
- `fonts/` — Monospace and pixel typography assets.
- `shapes/` — UI vector shapes and mask shaders.
- `theme.conf` — Theme metadata and default branding parameters.
- `install-pixel-sddm.sh` — Upstream helper script for deploying the theme to `/usr/share/sddm/themes/ii-pixel-sddm`.

## Manual Installation (Optional)

If you have SDDM installed and want to test or apply this theme manually:

```bash
# Preview or install via the upstream script with elevated privileges:
sudo ./install-pixel-sddm.sh
```

To test the theme inside a nested window without changing system configurations:
```bash
sddm-greeter-qt6 --test-mode --theme /home/hari/hari-dev0x/Projects/NexOS/extras/ii-pixel-sddm
```
