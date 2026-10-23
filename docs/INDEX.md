# NexUI Documentation Hub

Welcome to the canonical documentation for **NexUI** (Precision Linux Desktop Environment), designed by [Harinarayanan B. S.](https://github.com/hari-dev0x).

NexUI is a modern, high-performance desktop shell environment engineered for **CachyOS Linux** and **Arch Linux**, built on top of the **Niri** scrollable-tiling Wayland compositor and the **Quickshell** reactive Qt Quick / QML engine.

---

## Documentation Index

| Document | Description |
| :--- | :--- |
| **[Architecture Guide](ARCHITECTURE.md)** | Deep dive into the system architecture, presentation layer, supervisor lifecycle, and reactive data flow. |
| **[Installation & Deployment](INSTALLATION.md)** | Step-by-step setup instructions, automated scripts, dependency auditing, and post-install checks. |
| **[Keybindings Reference](KEYBINDS.md)** | Exhaustive list of keyboard shortcuts for the Niri compositor, Quickshell IPC, and system actions. |
| **[Configuration System](CONFIG.md)** | Complete guide to configuring themes, colors, panels, widgets, audio, wallpapers, and performance options. |
| **[Services & Lifecycle](SERVICES.md)** | Documentation on systemd user integration (`nexui.service`), supervisor daemon, D-Bus watcher, and IPC commands. |
| **[Niri Compositor Integration](NIRI.md)** | Window manager rules, scrollable-tiling layout, gesture navigation, animation profiles, and layer-shell integration. |
| **[Desktop Components](COMPONENTS.md)** | Breakdown of shell surfaces: LivingBar, Control Center, App Launcher, Spatial Panels, Notifications, and OSDs. |
| **[Troubleshooting & Diagnostics](TROUBLESHOOTING.md)** | Practical diagnostic runbook for display issues, audio streams, duplicate shells, and GPU policies. |
| **[Supported Systems & Requirements](SUPPORTED_SYSTEMS.md)** | Hardware prerequisites, distribution compatibility (CachyOS, Arch, Fedora, NixOS), and package matrices. |
| **[Rollback & Uninstallation](ROLLBACK.md)** | Safe removal instructions, automated configuration backups, and snapshot restoration procedures. |
| **[User & Operator Guide](../NEXUI_GUIDE.md)** | Complete CLI operations, supervisor architecture, and daily operator workflows. |
| **[Upstream & Third-Party Integration](../UPSTREAM.md)** | Upstream lineage, version pinning, and GPL-3.0 licensing compliance details. |

---

## Quick Navigation

- **Source Repository:** [github.com/hari-dev0x/NexOS](https://github.com/hari-dev0x/NexOS)
- **Issue Tracker:** [github.com/hari-dev0x/NexOS/issues](https://github.com/hari-dev0x/NexOS/issues)
- **Security Reporting:** [Private Vulnerability Disclosure](https://github.com/hari-dev0x/NexOS/security/advisories/new)
- **Upstream Foundation:** [iNiR by snowarch](https://github.com/snowarch/inir) and [illogical-impulse by end-4](https://github.com/end-4/dots-hyprland)

---

## System Architecture at a Glance

```text
┌────────────────────────────────────────────────────────┐
│               NexUI Precision Shell Surface            │
│       Quickshell (Qt 6 / QML) · LivingBar · NexFlow    │
├────────────────────────────────────────────────────────┤
│             Niri Wayland Compositor (KDL Config)       │
│       Scrollable Tiling · Layer-Shell · Direct Scanout │
├────────────────────────────────────────────────────────┤
│           Audio, Network & Hardware Management         │
│     PipeWire · WirePlumber · NetworkManager · BlueZ    │
├────────────────────────────────────────────────────────┤
│               Base Linux OS & Kernel                   │
│       CachyOS (Linux 7.2.x BORE) · Arch Linux          │
└────────────────────────────────────────────────────────┘
```
