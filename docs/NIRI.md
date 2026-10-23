# Niri Wayland Compositor Integration

**NexUI** is natively architected for **Niri**, an infinite horizontal scrollable-tiling Wayland compositor designed for fluid, keyboard-driven desktop productivity.

---

## 1. Modular Configuration Hierarchy

NexUI configures Niri through a modular split-file layout in `~/.config/niri/config.d/`:

| File | Purpose |
| :--- | :--- |
| `10-input-and-cursor.kdl` | Mouse sensitivity, touchpad gestures, natural scrolling, cursor themes |
| `20-layout-and-overview.kdl` | Column widths, default gaps, border styling, focus ring, spring dynamics |
| `30-window-rules.kdl` | Floating rules, default column placements, geometry filters for apps |
| `40-environment.kdl` | Wayland environment variables (`QT_QPA_PLATFORM=wayland`, etc.) |
| `50-startup.kdl` | Clean startup hooks and background daemons |
| `60-animations.kdl` | Bezier curve definitions for window movements and workspace transitions |
| `70-binds.kdl` | Keyboard shortcuts dispatching to NexUI IPC and compositor actions |
| `80-layer-rules.kdl` | Layer-shell rules (shadows, blur, exclusivity for Quickshell surfaces) |
| `90-user-extra.kdl` | Reserved for custom user overrides that survive automated updates |

---

## 2. Layer-Shell Rules & Wallpaper Surfaces

Quickshell surfaces communicate with Niri via the Wayland `zwlr-layer-shell-v1` protocol.

In `80-layer-rules.kdl`:
- **Top Bar (`iris-bar`, `living-bar`):** Marked with exclusive zone reserve so maximized or tiled windows cannot overlap the bar.
- **Control Center & Launcher:** Rendered on the `top` or `overlay` layer with keyboard grab and transparent backdrops.
- **Backdrop Blur:** Surfaces requesting compositor blur utilize Niri's hardware-accelerated blur pipeline when supported (`ext-background-effect-v1`).

---

## 3. Dynamic Configuration Reloading

Niri supports instant live configuration reloading without restarting running applications or terminating your session:

```bash
# Validate configuration syntax
niri validate

# Hot-reload running Niri session
niri msg action reload-config
```

---

## 4. Workspaces & Window Management Mechanics

Unlike traditional grid or manual tiling window managers, Niri arranges windows along an infinite horizontal ribbon:
- **Columns:** Windows can stand as individual columns or stack vertically inside a shared column.
- **Expel / Consume (<kbd>Mod</kbd> + <kbd>[</kbd> / <kbd>]</kbd>):** Combine multiple windows into a single tabbed/stacked column or expel them into independent columns.
- **Preset Widths (<kbd>Mod</kbd> + <kbd>R</kbd>):** Cycle column width between standard proportions (1/3, 1/2, 2/3, full).
- **Workspace Navigation (<kbd>Mod</kbd> + <kbd>1</kbd> .. <kbd>9</kbd>):** Switch between independent horizontal ribbons.
