# Supported Systems & Environments

## 1. Verified Tier 1 Distributions
The following distributions are actively tested and fully supported with automated package and configuration management:

- **CachyOS Linux** (Primary Reference Platform)
  - Kernel: Standard / BORE / EEVDF kernels
  - Package Manager: `pacman` with `paru` / `yay`
- **Arch Linux**
  - Up-to-date Arch base with multilib and AUR enabled

## 2. Community & Compatible Distributions (Manual Deps)
Any modern Linux distribution running Wayland can use NexOS by running `./install.sh --no-deps` after manually satisfying prerequisites:

- **EndeavourOS / Manjaro** (Arch-family)
- **Fedora Workstation 40+** (requires copr for quickshell)
- **NixOS / openSUSE Tumbleweed**

## 3. Required Desktop Components
- **Compositor**: Hyprland (0.40.0 or higher recommended, Lua configuration support enabled)
- **UI Engine**: Quickshell (`quickshell-git` from AUR)
- **Audio Engine**: PipeWire with WirePlumber
- **Terminal**: Kitty (default keybinds mapped) or Foot
- **File Manager**: Thunar (GTK3)

## 4. Hardware Requirements
- **Architecture**: x86_64
- **Graphics**: Vulkan / OpenGL ES 3.2+ compatible GPU (AMD Mesa, Intel Iris/Xe, NVIDIA 535+ with DRM modeset)
- **Display**: Any 1080p, 1440p, or 4K display (supports automatic fractional scaling)
