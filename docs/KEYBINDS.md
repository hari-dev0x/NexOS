# NexUI Keybindings Reference

This document provides a comprehensive cheat sheet of keyboard shortcuts for the **NexUI** desktop environment on the **Niri** Wayland compositor.

> **Key Notation:**<br>
> `<Mod>` or `<Super>` refers to the Windows / Command / Meta key on your keyboard.

---

## 1. Shell & Productivity Shortcuts

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Mod</kbd> + <kbd>Space</kbd> | **Application Launcher / Overview** | Opens the fuzzy-search application launcher with categories. |
| <kbd>Mod</kbd> + <kbd>D</kbd> | **Control Center** | Toggles the NexUI Control Center overlay with quick settings. |
| <kbd>Mod</kbd> + <kbd>S</kbd> / <kbd>Mod</kbd> + <kbd>,</kbd> | **NexUI Settings** | Opens the desktop shell settings manager. |
| <kbd>Mod</kbd> + <kbd>Escape</kbd> / <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>Q</kbd> | **Session & Power Menu** | Toggles lock, suspend, reboot, poweroff, and logout actions. |
| <kbd>Mod</kbd> + <kbd>V</kbd> | **Clipboard Manager** | Opens the visual clipboard history search and paste popup. |
| <kbd>Super</kbd> + <kbd>G</kbd> | **Overlay Toggle** | Toggles full-screen desktop dashboard / widgets overlay. |
| <kbd>Mod</kbd> + <kbd>/</kbd> | **Cheatsheet** | Shows the interactive desktop shortcut cheatsheet. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd> | **Wallpaper Selector** | Opens the visual wallpaper gallery picker. |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | **Cycle Panel Family** | Cycles between NexUI Island, Waffle, and II shell panel designs. |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>F</kbd> | **Audio Equalizer** | Opens PipeWire / EasyEffects audio equalizer controls. |
| <kbd>Ctrl</kbd> + <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | **Restart Desktop Shell** | Cleanly restarts `nexui.service` and Quickshell instance. |

---

## 2. Applications & Launchers

| Shortcut | Action | Target Command |
| :--- | :--- | :--- |
| <kbd>Mod</kbd> + <kbd>T</kbd> / <kbd>Mod</kbd> + <kbd>Return</kbd> | Terminal Emulator | `kitty` |
| <kbd>Super</kbd> + <kbd>E</kbd> | File Manager | `thunar` |
| <kbd>Super</kbd> + <kbd>W</kbd> | Default Web Browser | `xdg-open https://` |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd> | Screen Color Picker | `hyprpicker -a` |

---

## 3. Screen Capture, OCR & Recording

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| <kbd>Print</kbd> | Quick Region Screenshot | Captures selected region directly to clipboard and disk. |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Screenshot Menu | Interactive menu for display, window, or region capture. |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd> | OCR Text Grabber | Select a screen area to extract text via optical recognition. |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>A</kbd> | AI Visual Search | Analyze selected screen region with integrated multimodal AI. |
| <kbd>Mod</kbd> + <kbd>Alt</kbd> + <kbd>R</kbd> | Screen Recorder | Record video of selected screen area or active monitor. |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | Screen Recorder + Audio | Record screen with PipeWire microphone/system audio mix. |

---

## 4. Hardware & Media Keys

| Shortcut | Action |
| :--- | :--- |
| <kbd>XF86AudioRaiseVolume</kbd> | Increase output volume (+5%) |
| <kbd>XF86AudioLowerVolume</kbd> | Decrease output volume (-5%) |
| <kbd>XF86AudioMute</kbd> | Toggle audio mute |
| <kbd>XF86AudioMicMute</kbd> | Toggle microphone input mute |
| <kbd>XF86MonBrightnessUp</kbd> | Increase display brightness (+5%) |
| <kbd>XF86MonBrightnessDown</kbd> | Decrease display brightness (-5%) |
| <kbd>XF86AudioPlay</kbd> / <kbd>XF86AudioPause</kbd> | MPRIS Play / Pause toggle |
| <kbd>XF86AudioNext</kbd> | MPRIS Next track |
| <kbd>XF86AudioPrev</kbd> | MPRIS Previous track |

---

## 5. Niri Window Management & Navigation

| Shortcut | Action |
| :--- | :--- |
| <kbd>Mod</kbd> + <kbd>Q</kbd> | Close active focused window |
| <kbd>Mod</kbd> + <kbd>Left</kbd> / <kbd>H</kbd> | Focus column to the left |
| <kbd>Mod</kbd> + <kbd>Right</kbd> / <kbd>L</kbd> | Focus column to the right |
| <kbd>Mod</kbd> + <kbd>Up</kbd> / <kbd>K</kbd> | Focus window upward within column |
| <kbd>Mod</kbd> + <kbd>Down</kbd> / <kbd>J</kbd> | Focus window downward within column |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>Left</kbd> / <kbd>H</kbd> | Move column to the left |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>Right</kbd> / <kbd>L</kbd> | Move column to the right |
| <kbd>Mod</kbd> + <kbd>F</kbd> | Toggle window maximize / fullscreen |
| <kbd>Mod</kbd> + <kbd>R</kbd> | Switch window into preset column width |
| <kbd>Mod</kbd> + <kbd>[</kbd> / <kbd>]</kbd> | Consume or expel window from column |
| <kbd>Mod</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Focus workspace 1 through 9 |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Move window to workspace 1 through 9 |
| <kbd>Mod</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | Quit Niri compositor session |
