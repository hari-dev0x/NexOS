# NexUI Services & Lifecycle Management

This document details the background services, daemon supervisor, systemd user integration, and IPC architecture that power **NexUI**.

---

## 1. Systemd User Service Integration

NexUI is managed as a standard `systemd --user` service.

- **Primary Service Name:** `nexui.service`
- **Compatibility Alias:** `inir.service` (symlinked to maintain backward compatibility)
- **Service Unit File:** `~/.config/systemd/user/inir.service`
- **Session Dependency:** `~/.config/systemd/user/niri.service.wants/inir.service`

### Common Service Commands

```bash
# Check service health and live PID
systemctl --user status nexui.service

# Restart the desktop shell cleanly
systemctl --user restart nexui.service

# Stop the desktop shell
systemctl --user stop nexui.service

# Inspect systemd journal logs for NexUI
journalctl --user -u nexui.service -e --no-pager
```

---

## 2. Process Supervisor & Crash Guard

Behind `systemctl --user start nexui.service`, execution flows into the robust shell supervisor:

```text
systemd (PID 1)
   └── /usr/bin/bash /home/hari/.local/bin/inir run --session
        └── bash .../config/quickshell/reimagined/run-reimagined.sh _supervisor
             └── quickshell -p .../config/quickshell/reimagined
```

### Supervisor Features:
1. **Flock Lockfile (`/tmp/nexui-supervisor.lock`):** Guarantees strictly one supervisor instance can execute across user sessions.
2. **Tracked Shell PID (`/tmp/nexui-shell.pid`):** Allows instant signal dispatching and orphaned process cleanup.
3. **Crash Protection (Rate Limiting):** Prevents CPU spinning if a severe QML or driver error occurs:
   - If the shell exits 5 times in less than 10 seconds, the supervisor pauses automatic respawning.
   - It outputs diagnostic traces to `/tmp/nexui-shell.log` and fires a desktop notification via `notify-send`.
4. **Clean Signal Interception:** Handling `SIGTERM` or `SIGINT` propagates termination gracefully to Quickshell before unlinking lockfiles.

---

## 3. D-Bus Integration & StatusNotifierWatcher

NexUI acts as the system tray host on Wayland using the FreeDesktop StatusNotifierItem (SNI) specification:
- Registers the well-known D-Bus name: **`org.kde.StatusNotifierWatcher`** on the user session bus.
- Any background application (Discord, Steam, Nextcloud, NetworkManager applet) automatically surfaces its icon and context menu directly in the LivingBar tray cluster.

> [!IMPORTANT]
> Exactly one process may own `org.kde.StatusNotifierWatcher` at any time. The single-instance supervisor guarantees that competing shell launches do not produce D-Bus registration collisions.

---

## 4. Quickshell IPC Protocol

NexUI listens on a local Unix domain socket for real-time IPC messages from keybindings, scripts, and CLI wrappers.

### IPC Subcommands via `nexui` or `inir`:

```bash
# Toggle UI components
nexui overview toggle         # Application launcher & search
nexui iris controlCenter toggle # Iris Control Center
nexui clipboard toggle        # Clipboard history picker
nexui session toggle          # Power / lock / logout matrix
nexui settings                # Shell configuration GUI

# Screen Actions
nexui region screenshot       # Interactive region screenshot
nexui region ocr              # Optical character recognition
nexui region record           # Screen video recorder

# Media & Volume
nexui audio volumeUp          # Raise volume
nexui audio volumeDown        # Lower volume
nexui audio mute              # Toggle mute
nexui mpris playPause         # Play/pause active media stream
```
