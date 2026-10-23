# Supported Systems & Environments

## 1. Verified Tier 1 Distributions
The following distributions are actively tested and fully supported with automated package and configuration management:

- **CachyOS Linux** (Primary Reference Platform)
  - Kernel: Standard / BORE / EEVDF kernels
  - Package Manager: `pacman` with `paru` / `yay`
- **Arch Linux**
  - Up-to-date Arch base with multilib and AUR enabled

---

## 2. Community & Compatible Distributions (Manual Deps)
Any modern Linux distribution running Wayland can use NexUI by running `./install.sh --no-deps` after manually satisfying prerequisites:

- **EndeavourOS / Manjaro** (Arch-family)
- **Fedora Workstation 41+** (requires Qt 6.9+ and Quickshell package)
- **NixOS / openSUSE Tumbleweed**

---

## 3. Required Desktop Components
- **Compositor**: [Niri](https://github.com/YaLTeR/niri) (Primary recommended Wayland scrollable-tiling compositor)
- **UI Engine**: [Quickshell](https://git.outfoxxed.me/outfoxxed/quickshell) (version >= 0.3.1 with Qt 6.9+)
- **Audio Engine**: PipeWire with WirePlumber
- **Terminal**: Kitty (default keybinds mapped), Alacritty, or Foot
- **File Manager**: Thunar (GTK3) or Dolphin

---

## 4. Hardware Requirements
- **Architecture**: x86_64
- **Graphics**: Vulkan / OpenGL ES 3.2+ compatible GPU (AMD Mesa, Intel Iris/Xe, NVIDIA 535+ with DRM modeset)
- **Display**: 1080p, 1440p, or 4K display with Wayland fractional scaling support
