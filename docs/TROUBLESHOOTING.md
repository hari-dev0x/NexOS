# NexOS Troubleshooting & Diagnostics

## 1. Quickshell Topbar Fails to Render
If the bar crashes or does not display after login:
1. Check the supervisor log:
   ```bash
   cat "${XDG_RUNTIME_DIR:-/tmp}/sea-shell-supervisor.log"
   ```
2. Manually invoke Quickshell in debug mode:
   ```bash
   qs -c sea-shell
   ```
3. Ensure `quickshell` package is built with Wayland layer-shell protocol support.

## 2. Audio Spectrum (CAVA) Inactive
- Confirm PipeWire and WirePlumber are active:
  ```bash
  systemctl --user status pipewire wireplumber
  ```
- Ensure `cava` is installed and executable from the terminal.

## 3. Hyprland Keybindings Unresponsive
- Verify Hyprland loaded the sea-shell keybinds:
  ```bash
  hyprctl binds | grep -i "sea-shell"
  ```
- If you use custom bindings, ensure they do not conflict with `SUPER+Space` or `SUPER+S`.

## 4. Fonts or Icons Missing
- Install standard glyph and emoji fonts:
  ```bash
  sudo pacman -S noto-fonts noto-fonts-emoji ttf-ibm-plex
  ```
