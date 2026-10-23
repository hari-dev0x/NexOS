# NexUI Configuration Guide

This guide details how to customize and configure **NexUI**, including appearance options, theme presets, LivingBar morphology, audio settings, and performance profiles.

---

## 1. Configuration File Locations

NexUI stores user preferences in JSON format:
- **Primary Configuration Path:** `~/.config/inir/config.json` (or `~/.config/nexui/config.json`)
- **Default Baseline:** `config/quickshell/reimagined/defaults/default-config.json`
- **Theme Palettes:** `config/quickshell/reimagined/modules/common/ThemePresets.qml`

Changes written to `config.json` are monitored via inotify by Quickshell services and applied dynamically without needing a full shell reload.

---

## 2. Using the NexUI CLI to Read and Modify Settings

The `nexui` CLI provides intuitive subcommands to query and update options:

```bash
# Print the current configuration
nexui config

# Get a specific configuration key
nexui get appearance.theme
nexui get appearance.globalStyle

# Set configuration values
nexui set appearance.theme "nexui"
nexui set appearance.globalStyle "nexui"
nexui set appearance.transparency.enable true
nexui set appearance.transparency.backgroundTransparency 0.15

# Reset configuration to pristine defaults
nexui config reset
```

---

## 3. Core Configuration Sections

### A. Appearance & Theming (`appearance`)

```json
{
  "appearance": {
    "globalStyle": "nexui",
    "theme": "nexui",
    "transparency": {
      "enable": false,
      "automatic": true,
      "backgroundTransparency": 0.08,
      "contentTransparency": 0.90
    },
    "typography": {
      "fontFamily": "Inter",
      "sizeScale": 1.0
    },
    "desaturation": {
      "enable": false,
      "saturation": -0.7,
      "brightness": -0.15,
      "scope": "all"
    }
  }
}
```

#### Theme Presets
NexUI includes curated theme presets:
- `"nexui"`: Flagship obsidian dark theme (`#0C0E14` / `#12151D` / `#1E2433`) with Ice Blue accent (`#76A9FA`).
- `"auto"`: Dynamically extracts Material Design 3 palettes from current wallpaper via Matugen.
- `"angel"`: Celestial twilight with warm golden halos.
- `"regalia"`: Neutral-black chassis with restrained ivory and champagne accents.
- `"catppuccin-mocha"`: Calming pastel dark aesthetic.
- `"nord"`: Arctic-inspired cool blue palette.

### B. LivingBar & Island Customization (`iris.bar`)

```json
{
  "iris": {
    "bar": {
      "composition": "unified",
      "clockStyle": "compact",
      "navItems": ["workspaces", "clock", "media", "system"],
      "fullStart": ["workspaces"],
      "fullCenter": ["island"],
      "fullEnd": ["tray", "status", "power"]
    },
    "appearance": {
      "preset": "nexui",
      "density": 1.0,
      "expandedRadius": 24,
      "glass": {
        "mode": "wallpaper",
        "blur": 100,
        "tint": 58
      }
    }
  }
}
```

- **`composition`**: `"unified"` (continuous topbar capsule) or `"cluster"` (segmented floating islands).
- **`glass.mode`**: `"wallpaper"` (software pre-rendered dual-layer blur) or `"compositor"` (native Wayland `ext-background-effect-v1` blur).

### C. Performance & Hardware Acceleration (`performance`)

```json
{
  "performance": {
    "lowPower": false,
    "reduceAnimations": false,
    "compositorBlur": true,
    "blurBackend": "auto",
    "monitorGpu": true
  }
}
```

- **`lowPower`**: When `true`, disables intensive blur shaders and background timers to conserve laptop battery.
- **`reduceAnimations`**: Disables spring dynamics for instant transitions.
- **`monitorGpu`**: Toggles GPU polling. On hybrid laptops with NVIDIA dGPUs, NexUI automatically applies selective GPU policies to allow the dGPU to enter deep power-saving states when idle.

### D. GameMode Automatic Suppression

When GameMode activates (`gamemoded` signals a running 3D title):
- Desktop blur shaders are instantly bypassed.
- Heavy background polling is suspended.
- Topbar enters minimal mode to yield 100% GPU frame budget to the game.
