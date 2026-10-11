# NexOS System Architecture

**Creator:** Harinarayanan B. S. ([@hari-dev0x](https://github.com/hari-dev0x))  
**Repository:** [https://github.com/hari-dev0x/NexOS](https://github.com/hari-dev0x/NexOS)  
**License:** GNU General Public License v3.0 (GPL-3.0)

---

## 1. Architectural Philosophy

NexOS is engineered around the **Liquid Glass** and **OxygenOS-for-PC** design philosophy:
- **Restrained Optical Depth**: Dark charcoal/midnight surfaces (`#090A0F`, `#12151D`) with hairline borders (`#1E2330`) and subtle glass blurs (`backdrop-filter: blur(20px)`).
- **Physical Continuity**: The topbar serves as the primary contextual anchor. The center Dynamic Island morphs smoothly between clock, volume telemetry, charging alerts, and media controls.
- **Zero AI-Rice Clutter**: Clean geometric widgets, native SVG vector branding, intentional spacing, and reliable desktop ergonomics.

---

## 2. Layered System Stack

```text
┌──────────────────────────────────────────────────────────┐
│              NexOS Shell Presentation Layer              │
│       Quickshell (QML / C++) · ImpastoBar · Sea-Shell    │
├──────────────────────────────────────────────────────────┤
│           Wayland Display & Window Compositor            │
│                 Hyprland (Lua Configuration)             │
├──────────────────────────────────────────────────────────┤
│              Core Audio & Hardware Subsystems            │
│         PipeWire · WirePlumber · CAVA · Brightnessctl    │
├──────────────────────────────────────────────────────────┤
│              Base Operating System Distribution          │
│                CachyOS / Arch Linux (Linux Kernel)       │
└──────────────────────────────────────────────────────────┘
```

---

## 3. Component Breakdown

### A. Hardware Boot & Login (NexBoot)
- **Plymouth Splash (`config/boot/plymouth/`)**: 130-frame hardware assembly animation at 30 FPS followed by a glitch handoff sequence.
- **SDDM Greeter (`config/boot/sddm/`)**: Minimalist black theme with user selection, avatar resolution, and fluid password validation.
- **Handoff Synchronizer (`nexos-plymouth-quit.sh`)**: Guarantees deterministic lifecycle completion before passing framebuffer control to SDDM.

### B. Wayland Compositor (`config/hypr/`)
- Configured via native **Hyprland Lua API** (`hyprland.lua`).
- Modularity:
  - `general.lua`, `decoration.lua`: 10px rounding, 4-pass blur, custom drop shadows.
  - `animations.lua`: Bezier spring transitions for window motion.
  - `keybinds.lua`: Unified keyboard shortcuts (`SUPER+Space` launcher, `SUPER+S` control center, `SUPER+T` terminal).
  - `sea-shell/`: Environmental adaptations and dynamic matugen color palette injection.

### C. Quickshell Desktop Shell (`config/quickshell/sea-shell/`)
- **ImpastoBar (`impastobar/`)**:
  - `Bar.qml`: Top surface maintaining exclusive reserve across all displays.
  - `DynamicIsland.qml`: Morphing center capsule hosting media, calendar, notifications, and overview.
  - `ControlsPanel.qml`: Resident quick settings (Wi-Fi, Bluetooth, Power Profiles, Audio).
- **Resident Services (`impastobar/services/`)**:
  - `MediaService.qml`: MPRIS player tracking over D-Bus.
  - `CavaService.qml`: Real-time audio spectrum telemetry.
  - `NetworkService.qml` & `BluetoothService.qml`: Real-time device status and toggles.
- **Supervisor (`sea-bar-supervisor.sh`)**:
  - Independent process supervisor ensuring automatic bar restart upon Wayland connection resets without clobbering existing panels.

---

## 4. IPC Interface

The shell exposes instant, zero-latency IPC hooks via `qs -c sea-shell ipc call`:

| Endpoint | Action | Keybinding |
| :--- | :--- | :--- |
| `launcher toggle` | Reveals or dismisses floating app launcher | `SUPER + Space` / `CTRL + Space` |
| `settings toggle` | Opens resident Control Center / Settings | `SUPER + S` |
| `wallpaper next` | Smoothly transitions to next wallpaper | `SUPER + N` |
| `switcher next` | Activates visual Alt-Tab window switcher | `ALT + Tab` |
| `menu open` | Reveals focused window Global Menu bar | `SUPER + M` |
