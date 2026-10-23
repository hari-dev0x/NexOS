# NexUI Installation & Deployment Guide

This guide covers installing and deploying **NexUI** on **CachyOS Linux** and **Arch Linux** systems.

---

## 1. System Requirements

- **Operating System:** CachyOS Linux or Arch Linux (rolling release)
- **Display Server:** Wayland
- **Compositor:** [Niri](https://github.com/YaLTeR/niri) (recommended version >= 0.1.10)
- **Shell Engine:** [Quickshell](https://git.outfoxxed.me/outfoxxed/quickshell) (version >= 0.3.1 with Qt 6.9+)
- **Audio Stack:** PipeWire with WirePlumber
- **Required Fonts:** `Inter`, `Rubik`, `Oxanium`, `Material Symbols Rounded`, `noto-fonts`

---

## 2. Recommended Installation Method

Clone the authoritative repository, inspect changes, and run the automated installer:

```bash
# 1. Clone the repository
git clone https://github.com/hari-dev0x/NexOS.git
cd NexOS

# 2. Run a dry-run check (audits dependencies and displays actions without modifying system)
./install.sh --dry-run

# 3. Execute installation
./install.sh
```

---

## 3. Remote One-Line Installation

For a fresh CachyOS or Arch installation:

```bash
curl -fsSL https://raw.githubusercontent.com/hari-dev0x/NexOS/main/install.sh | bash
```

> [!NOTE]
> Review the remote script at [https://raw.githubusercontent.com/hari-dev0x/NexOS/main/install.sh](https://raw.githubusercontent.com/hari-dev0x/NexOS/main/install.sh) prior to running piped bash commands.

---

## 4. Installer Flags

| Flag | Description |
| :--- | :--- |
| `-y`, `--yes` | Non-interactive mode (automatically accepts prompts) |
| `--dry-run` | Audits system dependencies and prints planned operations without writing |
| `--no-deps` | Skips package manager; copies configuration files and assets only |
| `--boot` | Installs Plymouth boot splash and custom SDDM greeter (requires root) |
| `--uninstall` | Safely removes NexUI configurations and offers snapshot restoration |

---

## 5. Post-Installation Verification

1. **Verify the Desktop Service:**
   ```bash
   systemctl --user status nexui.service
   ```
   The service should display `Active: active (running)`.

2. **Verify Niri Configuration:**
   Reload Niri configuration dynamically:
   ```bash
   niri msg action reload-config
   ```

3. **Verify Shell Controls:**
   Test keybindings:
   - <kbd>SUPER</kbd> + <kbd>Space</kbd> — Open Centered Application Launcher
   - <kbd>SUPER</kbd> + <kbd>S</kbd> — Toggle Control Center
   - <kbd>SUPER</kbd> + <kbd>T</kbd> — Launch Terminal emulator (`kitty`)
   - <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>B</kbd> — Restart Desktop Shell

4. **CLI Diagnostics:**
   ```bash
   ./nexui doctor
   ```
   Ensures all required runtime tools, D-Bus sockets, and audio daemons are operational.
