# NexUI Desktop Components

This document details the visual components and surface architecture comprising the **NexUI** desktop experience.

---

## 1. LivingBar & The Dynamic Morphing Capsule

The **LivingBar** is the core anchor of the desktop experience, anchored to the top of your display with exclusive layer-shell reserve.

### Structural Sections:
1. **Workspace Indicators (Start):**
   - Directly linked to Niri's active column and workspace index.
   - Distinct visual state for focused window, active workspace, and background columns.
2. **Dynamic Morphing Capsule (Center):**
   - **Default State:** Displays current time and date in sleek optical typography.
   - **Volume Telemetry:** Expands smoothly when adjusting audio levels with a miniature visualizer and percentage pill.
   - **Charging & Battery Alerts:** Displays smooth AC plug/unplug animations with current charge status.
   - **Now Playing Media:** Displays current artist, title, playback progress, and animated audio equalizer waves.
   - **Notification Burst:** Morphs into a compact preview when high-priority notifications arrive.
3. **Status & Tray Cluster (End):**
   - Active network status (Wi-Fi SSID, Ethernet link state).
   - Bluetooth connection indicators.
   - Battery charge level and power profile badge.
   - System tray icons via `org.kde.StatusNotifierWatcher`.

---

## 2. Resident Control Center (<kbd>Mod</kbd> + <kbd>D</kbd>)

The Control Center provides zero-latency access to common system toggles without interrupting focused workflows:
- **Connectivity Cards:** Clickable toggle tiles for Wi-Fi and Bluetooth with direct access to network list and paired device management.
- **Audio Stream Mixer:** Master volume slider alongside dedicated sliders for individual running applications.
- **Display Brightness & Night Light:** Smooth hardware backlight slider with blue light reduction toggle.
- **System Telemetry:** Real-time CPU, RAM, and GPU utilization counters.
- **Power Profile Selector:** Fast switching between *Performance*, *Balanced*, and *Power Saver* modes.

---

## 3. Centered Application Launcher (<kbd>Mod</kbd> + <kbd>Space</kbd>)

A keyboard-first launcher designed for instantaneous application launching:
- **Instant Fuzzy Search:** Type any application name, executable binary, or description.
- **Category Filter Chips:** Fast navigation across `All`, `Internet`, `Development`, `Media`, `System`, and `Utilities`.
- **Inline Calculator & Unit Conversion:** Type math expressions (e.g., `48 * 12` or `100 USD in EUR`) for immediate calculation results.
- **Terminal Execution:** Prefix commands with `>` to launch commands in your default terminal emulator (`kitty`).

---

## 4. Clipboard History Manager (<kbd>Mod</kbd> + <kbd>V</kbd>)

- Preserves text snippets and image captures across user sessions.
- Full-text search over clipboard history.
- Click or press Enter to restore selected entry to primary clipboard and paste buffer.

---

## 5. On-Screen Displays (OSDs) & Notification System

- **Volume & Backlight OSDs:** Minimalist frosted glass capsules that appear floating near the top center when adjusting volume or display brightness via keyboard shortcuts.
- **Notification Toasts:** Layer-shell notification bubbles with rich action buttons, dismiss gestures, and app icons.
- **Do Not Disturb (DND):** Silences non-critical notification toasts while preserving badges in the notification history drawer.

---

## 6. Power & Session Matrix (<kbd>Mod</kbd> + <kbd>Escape</kbd>)

A clean, centered modal dialog providing one-click options to:
- **Lock Session:** Dispatches to the active screenlocker (`inir lock`).
- **Suspend / Sleep:** Suspends system to RAM.
- **Reboot:** Reboots the computer safely.
- **Power Off:** Initiates standard ACPI shutdown.
- **Log Out:** Exits Niri compositor session.

---

## 7. NexFlow Motion Architecture & Animation Engine

**NexFlow** is the dedicated motion rendering engine that drives all animated interactions across NexUI components:

- **Morphing Physics:** Underpins the LivingBar's adaptive transitions using real-time spring dynamics (`IrisSpring.qml`).
- **Surface Transitions:** Powers modal overlays, drawer reveals, and dropdown expansions using calibrated cubic-bezier easing (`Appearance.qml`).
- **Compositor Synchronization:** Connects shell interactions with Niri window animations (`60-animations.kdl`), delivering unified motion behavior across floating panels, tiled columns, and desktop surfaces.
