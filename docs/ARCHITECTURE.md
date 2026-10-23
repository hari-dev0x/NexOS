# NexUI System Architecture

**Creator & Maintainer:** Harinarayanan B. S. ([@hari-dev0x](https://github.com/hari-dev0x))<br>
**Repository:** [https://github.com/hari-dev0x/NexOS](https://github.com/hari-dev0x/NexOS)<br>
**License:** GNU General Public License v3.0 (GPL-3.0)
**Platform Target:** CachyOS Linux / Arch Linux on Wayland

---

## 1. Architectural Philosophy

NexUI is engineered as a precision desktop environment built on mathematical ergonomics, physical visual continuity, and low-latency Wayland protocols.

Key architectural tenets:
1. **Restrained Optical Depth**: Dark obsidian/charcoal surfaces (`#0C0E14` base, `#12151D` low surface, `#1E2433` elevated surface) with Ice Blue accents (`#76A9FA`), disciplined hairline boundaries (`#334155`), and responsive optical blurs.
2. **Physical Continuity**: The topbar serves as the primary contextual anchor. The LivingBar center capsule dynamically expands and morphs across system states: time, volume changes, AC charging, audio playback, and notification bursts.
3. **Deterministic Single-Instance Lifecycle**: The desktop shell is managed as a unified user service (`nexui.service`), backed by a file-locked process supervisor that enforces zero duplicate instances and automatic crash backoff.
4. **Compositor Native Integration**: Directly integrated with the **Niri** scrollable-tiling Wayland compositor through Wayland layer-shell protocol, IPC sockets, and native animation curves.

---

## 2. Multi-Layer System Stack

```text
┌────────────────────────────────────────────────────────┐
│                   NexUI Presentation                   │
│         Quickshell QML Engine (Qt 6.9+ / C++)          │
│   • LivingBar (Dynamic Morphing Center Island)         │
│   • Iris / Waffle / II Panel Families                  │
│   • Control Center, Launcher, App Overview, OSDs       │
├────────────────────────────────────────────────────────┤
│                 Wayland Compositor Layer               │
│               Niri (KDL Configuration)                 │
│   • Wayland Protocols: zwlr-layer-shell-v1             │
│   • ext-background-effect-v1 (Native Hardware Blur)    │
│   • Direct Scanout & Scrollable Horizontal Tiling      │
├────────────────────────────────────────────────────────┤
│             System Interprocess Communication          │
│   • Systemd User Services (nexui.service)              │
│   • D-Bus: org.kde.StatusNotifierWatcher               │
│   • Unix Domain Sockets: Niri IPC & Quickshell IPC     │
├────────────────────────────────────────────────────────┤
│           Hardware Telemetry & Device Control          │
│   • PipeWire / WirePlumber (Audio & Media Streams)     │
│   • NetworkManager & BlueZ (Connectivity)              │
│   • Brightnessctl & UPower (Power & Display Backlight) │
├────────────────────────────────────────────────────────┤
│            Base Linux Kernel & Distribution            │
│   • CachyOS (BORE CPU Scheduler, CachyOS Kernel)       │
│   • Arch Linux Ecosystem (pacman / AUR / systemd)      │
└────────────────────────────────────────────────────────┘
```

---

## 3. Component Breakdown

### A. LivingBar & Dynamic Morphing Capsule
- **Path:** `config/quickshell/reimagined/livingbar.qml` & `modules/iris/bar/`
- **Responsibilities:**
  - Full-width top layer surface with exclusive Wayland layer-shell reserve.
  - Hosts the dynamic morphing island that responds to hardware audio, battery status, notifications, and calendar events.
  - Renders workspace indicators reflecting Niri's active column positions and window counts.
  - Integrates system tray via `org.kde.StatusNotifierWatcher` D-Bus interface.

### B. Control Center & System Telemetry
- **Shortcut:** <kbd>SUPER</kbd> + <kbd>S</kbd>
- **Responsibilities:**
  - Instant zero-latency pre-rendered overlay panel.
  - Master toggles for Wi-Fi, Bluetooth, Night Light, GameMode, and Do Not Disturb.
  - Audio sinks and source selector with individual stream volume sliders.
  - Power profiles (Performance, Balanced, Power Saver) via power-profiles-daemon.

### C. Application Launcher & Search
- **Shortcut:** <kbd>SUPER</kbd> + <kbd>Space</kbd>
- **Responsibilities:**
  - Modern keyboard-centric launcher with fuzzy search indexing installed `.desktop` files.
  - Categorized chips (`All`, `Internet`, `Development`, `Media`, `System`, `Utilities`).
  - Integrated math expression evaluation and system command runner.

### D. Session & Power Matrix
- **Shortcut:** <kbd>SUPER</kbd> + <kbd>Escape</kbd>
- **Responsibilities:**
  - Lock Screen (`inir lock` / `swaylock` / `waylock`).
  - Session Suspend, Hibernation, Reboot, and Poweroff.
  - Clean termination of user graphical sessions.

---

## 4. Supervisor & Process Architecture

NexUI enforces a robust single-instance lifecycle:
1. **Systemd Service (`~/.config/systemd/user/nexui.service`):**
   - Aliased to `inir.service` to preserve full backward compatibility.
   - Automatically bound to `niri.service` and started on graphical login.
2. **Supervisor Daemon (`run-reimagined.sh`):**
   - Utilizes `flock` on `/tmp/nexui-supervisor.lock` to guarantee exactly one supervisor runs at any time.
   - Tracks child shell PID in `/tmp/nexui-shell.pid`.
   - Rate limits crash loops: if the shell exits more than 5 times within 10 seconds, spawning halts and triggers a desktop alert.
   - Cleans up child processes and lockfiles on `SIGTERM`, `SIGINT`, or system shutdown.

---

## 5. Design System Tokens

The visual foundation is defined in `Appearance.qml` and `ThemePresets.qml`:

```yaml
Colors:
  Background:       "#0C0E14"  # Base layer 0
  Surface:          "#12151D"  # Surface layer 1
  Elevated:         "#1E2433"  # Elevated surface layer 2
  Elevated High:    "#283042"  # Highlighted surface layer 3
  Text Primary:     "#E2E8F0"  # High-contrast typography
  Text Secondary:   "#94A3B8"  # Slate secondary reading
  Accent (Ice Blue):"#76A9FA"  # Signature NexUI blue
  Danger / Error:   "#F87171"  # Destructive action indicator
  Muted / Outline:  "#475569"  # Hairline borders and subtle dividers

Geometry:
  Radius Small:     10px       # Buttons, badges, controls
  Radius Normal:    16px       # Cards, widgets, popovers
  Radius Large:     24px       # Panels, launcher, control center
```

---

## 6. Attributions & Licensing

- **Product:** NexUI by Harinarayanan B. S.
- **License:** GNU General Public License v3.0 (GPL-3.0)
- **Upstream Foundations:**
  - iNiR: Copyright (C) [snowarch](https://github.com/snowarch/inir) (GPL-3.0)
  - illogical-impulse: Copyright (C) [end-4](https://github.com/end-4/dots-hyprland) (GPL-3.0)
