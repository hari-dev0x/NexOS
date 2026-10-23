# NexUI Troubleshooting & Diagnostics Runbook

This guide provides practical step-by-step diagnostic procedures for resolving common issues with **NexUI**, **Niri**, and **Quickshell**.

---

## 1. Top Bar / Shell Does Not Appear or Disappears

### Step A: Check systemd service status
```bash
systemctl --user status nexui.service
```
- If the service is in a failed state or inactive, inspect recent output:
  ```bash
  journalctl --user -u nexui.service -n 50 --no-pager
  ```

### Step B: Inspect the shell log
```bash
cat /tmp/nexui-shell.log
```
Or use the built-in CLI:
```bash
nexui logs -n 50
nexui logs --issues
```

### Step C: Restart the shell cleanly
```bash
nexui restart
# Or via systemd:
systemctl --user restart nexui.service
```

---

## 2. Preventing Duplicate Shell Instances

NexUI uses a file-locked supervisor to guarantee that exactly one instance of Quickshell runs. If you suspect an orphaned instance:

```bash
# Check running quickshell processes:
pgrep -fl "qs|quickshell"

# If multiple processes exist:
systemctl --user stop nexui.service
killall -9 qs quickshell 2>/dev/null
rm -f /tmp/nexui-supervisor.lock /tmp/nexui-supervisor.pid /tmp/nexui-shell.pid
systemctl --user start nexui.service
```

Verify that only one `quickshell` PID is running:
```bash
pgrep -fl "quickshell"
```

---

## 3. Audio & Volume Telemetry Issues

If volume sliders or the media visualizer do not respond:

1. Confirm PipeWire and WirePlumber are active:
   ```bash
   systemctl --user status pipewire wireplumber
   ```
2. Verify audio playback with `wpctl`:
   ```bash
   wpctl status
   ```
3. Test adjusting volume directly via CLI:
   ```bash
   nexui audio volumeUp
   nexui audio volumeDown
   ```

---

## 4. Keybindings Inhibited or Unresponsive

If keyboard shortcuts stop responding (e.g. after exiting a virtual machine or remote desktop client):
- Press <kbd>Super</kbd> + <kbd>G</kbd> to force re-enable the keybinding grab.
- Verify Niri configuration syntax:
  ```bash
  niri validate
  ```
- Hot-reload Niri configuration:
  ```bash
  niri msg action reload-config
  ```

---

## 5. NVIDIA Hybrid Laptop Power Optimization

On hybrid laptops with Intel/AMD integrated graphics and an NVIDIA discrete GPU:
- Quickshell's Vulkan layer may inadvertently wake the NVIDIA dGPU during initialization.
- NexUI includes an automatic GPU policy filter that keeps the NVIDIA card suspended when only desktop UI rendering is active.
- To verify your dGPU power state:
  ```bash
  cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
  ```
  It should report `suspended` when running on battery without 3D apps open.

---

## 6. Missing Fonts or Glyphs

If icons render as rectangles or missing glyphs:
```bash
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome
fc-cache -fv
```
NexUI bundles its primary fonts (`Inter`, `Rubik`, `Oxanium`, `Material Symbols Rounded`) inside `config/quickshell/reimagined/assets/fonts/` and loads them dynamically via QML `FontLoader`.

---

## 7. Running Full Automated Diagnostics

Run the comprehensive health check:
```bash
nexui doctor
```
This tests all essential dependencies, D-Bus services, Wayland protocols, and configuration integrity.
