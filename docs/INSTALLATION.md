# NexOS Installation Guide

## 1. Trust & Safe Remote Installation
We recommend inspecting the repository before executing installation scripts on your system.

### Option A: Clone & Inspect (Recommended)
```bash
git clone https://github.com/hari-dev0x/NexOS.git
cd NexOS

# Review planned actions without making any system changes:
./install.sh --dry-run

# Run standard installation:
./install.sh
```

### Option B: One-Command Remote Installation
For a clean, non-interactive setup on an Arch/CachyOS machine:
```bash
curl -fsSL https://raw.githubusercontent.com/hari-dev0x/NexOS/main/install.sh | bash
```

> [!NOTE]
> Piping remote scripts directly into `bash` executes code on your machine. Inspect the remote script first by visiting [install.sh](https://raw.githubusercontent.com/hari-dev0x/NexOS/main/install.sh).

---

## 2. Command Line Flags
| Flag | Description |
| :--- | :--- |
| `-y`, `--yes` | Non-interactive execution (auto-confirms prompts) |
| `--dry-run` | Audits dependencies and outputs planned file operations without writing |
| `--no-deps` | Skips package manager invocation; installs configuration files only |
| `--boot` | Deploys Plymouth boot animation and SDDM login theme (requires root elevation) |
| `--uninstall` | Initiates safe removal and rollback |

---

## 3. Post-Installation Verification
1. Reload Hyprland: `hyprctl reload` or press `SUPER + SHIFT + R`.
2. Verify Quickshell topbar: If the bar does not immediately appear, restart the supervisor:
   ```bash
   sh ~/.config/quickshell/sea-shell/sea-bar-supervisor.sh --restart
   ```
3. Test keybindings:
   - `SUPER + Space`: Open App Launcher
   - `SUPER + S`: Open Control Center
   - `SUPER + T`: Open Terminal
