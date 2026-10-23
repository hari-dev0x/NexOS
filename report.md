# NexUI — Phase 1 Change Log & Architecture Report

> [!NOTE]
> **Project Rebrand Notice**: This project has been officially rebranded from **NexOS / iNiR** to **NexUI**, authored by **Harinarayanan.B.S**. Historical log entries below retain original phase references for architectural provenance and audit tracking.

## Mission & Scope
Phase 1 of NexOS Reimagined delivers the foundational design system and first cohesive spatial desktop UI architecture. This phase establishes canonical design tokens, spatial surface primitives, the adaptive Drop/Merge motion framework, the unified top-bar composition with stable geometric centering, origin-based expansion, a hidden dormant companion compatibility interface, and a minimal evaluation workspace.

All Phase 1 work is strictly isolated on branch `NexOS-reimagined` of repository `https://github.com/hari-dev0x/NexOS`.

---

## Git Safety & Isolation Record
- **Branch isolation:** Created dedicated branch `NexOS-reimagined` derived from `origin/main` (commit `af5794f`).
- **Default branch protection:** Branch `main` was inspected and remains completely untouched.
- **Preservation of user work:** Unstaged WIP modifications on `main` in `config/quickshell/sea-shell/` were securely preserved via `git stash push -m "WIP on sea-shell before NexOS-reimagined" --include-untracked`, leaving the working tree completely clean and preventing data loss.
- **Active desktop shell protection:** Running desktop shell `sea-shell` (PID 2211, Wayland connection `wayland-1`) was kept active and untouched throughout development and testing.
- **Evaluation policy:** Code and syntax validation was conducted using `qmllint` and headless Quickshell launch testing. In accordance with system instructions, no automated visual audits, screenshots, or computer vision evaluations were performed.

---

## Detailed File Modification Log

### 1. `config/quickshell/reimagined/tokens/Tokens.qml` & `tokens/qmldir`
- **Action:** Created.
- **What changed:** Established the canonical centralized design token singleton `Tokens`.
- **Why it changed:** Fulfills the requirement for an authoritative token system with strict canonical color values, 4px spacing hierarchy, nominal corner radii, typography metrics, and specular edge treatments.
- **Responsibilities:**
  - Canonical Palette:
    - Background: `#0C0E14`
    - Surface: `#12151D`
    - Elevated: `#1E2433`
    - Primary Text: `#E2E8F0`
    - Secondary Text: `#94A3B8`
    - Ice Blue Accent: `#76A9FA`
    - Danger: `#F87171`
    - Muted: `#475569`
  - 4px Spacing Scale: `s1: 4`, `s2: 8`, `s3: 12`, `s4: 16`, `s6: 24`, `s8: 32`.
  - Nominal Radii: `rControl: 10`, `rCard: 16`, `rMajor: 24`, `rPill: 9999`.
  - Typography: System sans font (`Adwaita Sans`), monospace (`JetBrainsMono Nerd Font`), type scale (`tCaption: 11` to `tTitle: 24`).
  - Specular rim & hairline borders (`borderGlass`, `specularRim`, `specularHighlight`, `hairline`).
- **Validation:** Validated via `qmllint` with 0 errors.

### 2. `config/quickshell/reimagined/motion/MotionEngine.qml` & `motion/qmldir`
- **Action:** Created.
- **What changed:** Built the centralized motion engine singleton `MotionEngine`.
- **Why it changed:** Implements the required adaptive Drop/Merge motion engine and cubic-bezier easing curves inspired by the `transitions.dev` reference.
- **Responsibilities:**
  - Modes: `modeAdaptive` ("adaptive", default), `modeDrop` ("drop"), and `modeMerge` ("merge").
  - Curves: Easing cubic-bezier `(0.16, 1.0, 0.3, 1.0)` entry curve and `(0.7, 0.0, 0.84, 0.0)` exit curve, configured via 6-point bezier coordinate arrays.
  - Durations: `durationMicro` (160ms), `durationFast` (200ms), `durationSpatial` (300ms), `durationMerge` (340ms).
  - Reduced Motion Support: `reducedMotion` toggle immediately snaps durations to 0ms.
- **Validation:** Validated via `qmllint` with 0 errors.

### 3. `config/quickshell/reimagined/components/NexLogo.qml`
- **Action:** Created.
- **What changed:** Native vector QtQuick.Shapes implementation of the official NexOS 4-part geometric emblem.
- **Why it changed:** Derives the authoritative mark verified from `/home/hari/hari-dev0x/Projects/logo/Main design.png` into clean, scalable vector paths without raster blur or bitmap dependencies.
- **Responsibilities:**
  - Monolithic geometry: Left Vertical Stem, Upper Diagonal Blade, Lower Diagonal Blade, and Right Vertical Stem.
  - Proportional vector scaling via base coordinate bounding box (294x300).
  - Configurable `size`, `color`, `accent`, and optional framing card badge.
- **Validation:** Validated via `qmllint` with 0 errors.

### 4. Spatial Component Language
#### `config/quickshell/reimagined/components/SpatialGlass.qml`
- **Action:** Created.
- **What changed:** Core spatial substrate primitive.
- **Responsibilities:** Translucent glass surface (`Tokens.surfaceGlass`), subtle outer ambient depth border, top specular rim highlight, interactive hover/active states, and hosted child content container.
- **Validation:** Validated via `qmllint` with 0 errors.

#### `config/quickshell/reimagined/components/SpatialCard.qml`
- **Action:** Created.
- **What changed:** Structured content container component.
- **Responsibilities:** Opaque elevated surface (`Tokens.elevated`), nominal 16px radius, 4px spacing scale padding (`Tokens.s4`), specular hairline, and keyboard focus highlight.
- **Validation:** Validated via `qmllint` with 0 errors.

#### `config/quickshell/reimagined/components/SpatialToggle.qml`
- **Action:** Created.
- **What changed:** Tactile accessible switch.
- **Responsibilities:** 44x24 track, 18x18 sliding thumb with bezier spring animation, Ice Blue active fill (`#76A9FA`), Muted inactive fill (`#475569`), Space/Enter keyboard accessibility, and optional title/description labels.
- **Validation:** Validated via `qmllint` with 0 errors.

#### `config/quickshell/reimagined/components/SpatialSlider.qml`
- **Action:** Created.
- **What changed:** Precision interactive slider.
- **Responsibilities:** Track with filled accent bar, circular thumb with specular highlight and hover enlargement, percentage readout formatted in monospace font, and keyboard arrow key step navigation.
- **Validation:** Fixed attached Layout property error; validated via `qmllint` and quickshell runtime with 0 errors.

### 5. `config/quickshell/reimagined/components/OriginExpansion.qml` & `components/qmldir`
- **Action:** Created.
- **What changed:** Spatial origin-based expansion container.
- **Responsibilities:**
  - Tracks triggering control's geometry (`originX`, `originY`, `originWidth`, `originHeight`).
  - Implements Adaptive (scale & translate from origin), Drop (vertical unroll from bar anchor), and Merge (continuous geometric morph) expansion.
  - Anchors visual indicator tab pointing directly to the trigger item.
  - Supports clean dismissal via outside clicks or Escape key without blocking fullscreen desktop input when closed.
- **Validation:** Validated via `qmllint` with 0 errors.

### 6. `config/quickshell/reimagined/companion/NexCompanionContract.qml` & `companion/qmldir`
- **Action:** Created.
- **What changed:** Inactive compatibility contract interface for the Nex companion.
- **Why it changed:** Establishes the lifecycle contract for future companion capabilities while remaining completely dormant, with zero background threads, zero network calls, and zero IPC overhead.
- **Responsibilities:**
  - Lifecycle States: `stateIdle` ("idle"), `stateFocused` ("focused"), `stateWorking` ("working"), `stateWaiting` ("waiting"), `stateUnavailable` ("unavailable").
  - Default status: `isActive: false`, `currentState: stateUnavailable`.
  - Methods & Signals: `activate()`, `deactivate()`, `dispatchQuery(prompt)`, `cancelCurrentTask()`, `stateTransition`, `promptDispatched`, `responseArrived`.
- **Validation:** Validated via `qmllint` with 0 errors.

### 7. Unified Top Bar Architecture
#### `config/quickshell/reimagined/bar/WorkspacesIndicator.qml`
- **Action:** Created.
- **Responsibilities:** Workspace indicators (1..4) with animated active chip pill expanding in Ice Blue accent.

#### `config/quickshell/reimagined/bar/FloatingIsland.qml`
- **Action:** Created.
- **Responsibilities:**
  - Compact resting capsule (168x34) with stable geometric centering on `horizontalCenter`.
  - Animated activity waveform / status indicator, hover highlight, and click trigger for expanded panel.

#### `config/quickshell/reimagined/bar/StatusCluster.qml`
- **Action:** Created.
- **Responsibilities:**
  - Telemetry chips: Volume (with icon & percentage), Network (Wi-Fi SSID), Battery (percentage & health), Clock (realtime 12h formatted time), and Control Center button.
  - Exposes trigger item aliases for origin expansion.

#### `config/quickshell/reimagined/bar/IslandExpandedPanel.qml`, `VolumePanel.qml`, `NetworkPanel.qml`, `ControlCenterPanel.qml`
- **Action:** Created.
- **Responsibilities:**
  - `IslandExpandedPanel`: Media preview card, playback controls, and real-time motion mode switcher (Adaptive / Drop / Merge).
  - `VolumePanel`: Master volume slider, mute toggle, audio status.
  - `NetworkPanel`: Wi-Fi toggle, active network details, connection telemetry.
  - `ControlCenterPanel`: 4-tile quick setting grid (Bluetooth, DND, Night Light, Reduced Motion), display & volume sliders, and companion contract status inspector.

#### `config/quickshell/reimagined/bar/TopBar.qml` & `bar/qmldir`
- **Action:** Created.
- **Responsibilities:** Assembles left cluster (NexLogo + Workspaces), geometrically centered FloatingIsland, and right StatusCluster into a single unified capsule (38px height) with full origin expansion overlays and outside dismiss handling.
- **Validation:** Validated via `qmllint` and quickshell runtime with 0 errors.

### 8. `config/quickshell/reimagined/desktop.qml`, `shell.qml`, `qmldir`, `run-reimagined.sh`
- **Action:** Created.
- **What changed:** Minimal desktop workspace and isolated Quickshell entrypoint.
- **Responsibilities:**
  - `desktop.qml` (`DesktopWorkspace`): Renders canonical background `#0C0E14`, top bar, and 4 interactive test cards evaluating tokens, spatial components, motion modes, and companion contract.
  - `shell.qml`: Configures Quickshell `ShellRoot` with an isolated `FloatingWindow` (1280x840) to evaluate the entire shell without interfering with running desktop panels or Wayland layers.
  - `run-reimagined.sh`: Safe helper script with `check`, `run`, and `stop` actions.
- **Validation:** Successfully compiled and loaded via `quickshell -p config/quickshell/reimagined` with zero errors.

---

## Validation Summary

| Test | Command / Method | Result | Notes |
|---|---|---|---|
| Git Branch & Isolation | `git branch -a`, `git status` | PASS | Work strictly isolated on `NexOS-reimagined`; `main` untouched; uncommitted user work preserved in `git stash`. |
| Static QML Lint | `find config/quickshell/reimagined -name "*.qml" -exec qmllint {} +` | PASS | All components validated with 0 errors and 0 warnings. |
| Component Path Check | `./config/quickshell/reimagined/run-reimagined.sh check` | PASS | All files and singletons discovered cleanly. |
| Quickshell Runtime Compilation | `quickshell -p config/quickshell/reimagined` | PASS | Configuration loaded cleanly with status `Configuration Loaded`. |
| Active Shell Coexistence | `quickshell list --all` | PASS | Host `sea-shell` process (PID 2211) remained untouched and fully running. |

---

## Known Assumptions & Next Phases
- **Phase 1 Boundary:** Features outside Phase 1 (full application launcher, capture/screenshot editor, terminal GUI, live wallpapers, widget platform, system settings application, and lock-screen authentication) were intentionally omitted.
- **Compositor Services:** Hardware volume/brightness/network backend bindings will be attached to system services in Phase 2; in Phase 1, UI states are fully reactive and functional within the spatial shell framework.


---

## Phase 1 Correction Log: Native Spatial Capsule & Source-Reused Audio Implementation

### 1. Architectural Rework: Unified Spatial Control Surface
- **What changed:** Replaced detached rectangular dropdown panels (`OriginExpansion.qml`) with a continuous, native morphing control surface ([`SpatialCapsuleSurface.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/SpatialCapsuleSurface.qml)) embedded directly into [`TopBar.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/TopBar.qml).
- **Physical growth model:** When a control is clicked (e.g., Volume chip, Center Island, or Control Center), the capsule region physically grows both horizontally and vertically directly from that control's location:
  - Anchors flush with the top bar's top margin (`y: Tokens.barTopMargin = 8px`).
  - Animates width from the trigger's compact width to the content's calculated target width (`440px` for Sound).
  - Animates height from the compact bar height (`38px`) to the content's required height (dynamically calculated based on active audio streams and output devices).
  - Animates horizontal position from the trigger's coordinate to the centered target position, clamped safely within screen margins.
  - Morphs corner radius from full pill (`19px`) to card radius (`24px`).
- **Coherent switching:** Switching between controls (e.g., from Volume to Control Center) smoothly glides dimensions and position on the same animation clock without abrupt close/reopen cycles.
- **Dismissal:** Dismisses naturally via clicking the active trigger chip again, clicking outside the expanded surface, or pressing `Escape`. Clicks and slider drags inside the expanded surface never trigger unexpected closures.

### 2. Direct Source Reuse: Impasto Audio System & Sound Surface
Reused and adapted directly from the authoritative Impasto reference repository (`https://github.com/andreumassanet/impasto`, GPL-3.0 License by Andreu Massanet):

#### A. [`services/AudioService.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/services/AudioService.qml)
- **Source:** [`impasto/services/AudioService.qml`](file:///home/hari/.config/quickshell/nexos/impasto-topbar/services/AudioService.qml).
- **Capabilities & Responsibilities:**
  - Direct reactive PipeWire integration via `Quickshell.Services.Pipewire` with `PwObjectTracker`.
  - Binds live system sink (`Pipewire.defaultAudioSink`) and source (`Pipewire.defaultAudioSource`).
  - Discovers all available physical audio output nodes (`outputs`), active per-application playback streams (`streams`), microphone input nodes (`inputs`), and recording capture streams (`captures`).
  - Exposes reactive muting, master level adjustments (`setVolume`), stream volume control (`setStreamVolume`), stream mute toggles (`toggleStreamMute`), microphone volume control (`setSourceVolume`), and output/input device routing (`choose`, `chooseInput`).
  - Dynamically calculates exact panel dimensions (`panelWidth: 440`, `panelHeight`).
- **Compatibility Adaptation:** Removed external theme couplings, bound directly to `Tokens.qml`, and resolved reserved JavaScript variable names (`short` -> `shortName`) for strict QtQuick compatibility.

#### B. [`bar/SoundDetail.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/SoundDetail.qml)
- **Source:** [`impasto/bar/island/SoundDetail.qml`](file:///home/hari/.config/quickshell/nexos/impasto-topbar/bar/island/SoundDetail.qml).
- **Capabilities & Responsibilities:**
  - Header: [`DetailHeading.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/DetailHeading.qml) displaying active output device name, PipeWire live status dot, and back/close button.
  - Section 1 (Master Output): [`LevelRow.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/LevelRow.qml) with volume icon, device name, and full-track tactile slider with mute toggle.
  - Section 2 (Applications): Repeater over active PipeWire streams, showing per-application icon, application name, individual volume slider, and individual mute button.
  - Section 3 (Output Devices): Repeater over physical audio sinks via [`DetailChoice.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/DetailChoice.qml) with device selection radio checkmarks and live device routing.
  - Section 4 (Microphone & Input): Microphone level slider, mute toggle, and available input source selectors.

#### C. Tactile Sliders & Rows
- [`bar/SliderRow.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/SliderRow.qml): Adapted from [`impasto/components/SliderRow.qml`](file:///home/hari/.config/quickshell/nexos/impasto-topbar/components/SliderRow.qml). Full-width tactile slider with animated filled accent track, icon mute target, and monospace percentage readout.
- [`bar/LevelRow.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/LevelRow.qml): Adapted from [`impasto/bar/island/LevelRow.qml`](file:///home/hari/.config/quickshell/nexos/impasto-topbar/bar/island/LevelRow.qml). Uniform row with mark (app icon or glyph), label, and SliderRow.
- [`bar/DetailHeading.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/DetailHeading.qml), [`DetailSection.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/DetailSection.qml), [`DetailChoice.qml`](file:///home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/bar/DetailChoice.qml).

### 3. Transition & Motion Alignment
- Easing and duration are directly aligned with Impasto's authoritative morphing model (`durationMerge: 340ms`, `Easing.OutCubic`).
- Animated properties (`x`, `width`, `height`, `radius`, `opacity`) execute on a single coordinated clock to eliminate per-frame jitter.
- Rest state retains the geometrically centered floating island and compact status cluster.

---

# NexOS → Complete iNiR-Based Shell Architecture Migration Plan

## 1. Executive Summary & Upstream Foundation

This document details the architectural migration of NexOS into a full, genuine **iNiR-based desktop shell**, superseding previous isolated prototypes while maintaining strict isolation, Git history preservation, and host desktop safety.

- **Primary Upstream Source:** `https://github.com/snowarch/iNiR`
- **Upstream Version:** `v2.33.0` (commit `48cdcec`, GPL-3.0 License by illogical-impulse team)
- **Local Target Workspace:** `~/hari-dev0x/Projects/NexOS`
- **Active Git Branch:** `NexOS-reimagined` (HEAD: `a5b7d90`)
- **Host Desktop Environment:** CachyOS Linux (Kernel 6.17), Hyprland 0.56.2, PipeWire 1.6.9, Quickshell 0.3.1 (`/usr/bin/qs`)
- **Host Shell Safety:** Active shell `sea-shell` (PID 2211, Wayland connection `wayland-1`) remains completely untouched and active throughout.

---

## 2. In-Depth Component Audit & Source Trace

### A. iRiS / Island Origin-Based Morphing Architecture
- **Origin & State Dispatch:**
  - `modules/iris/bar/IrisIsland.qml`: Calculates clicked piece screen coordinates via `partRect(part)` or chassis bounds via `chassisBody()`.
  - On interaction: Dispatches `root.toggleBubbleCard(kind, part, source)`, storing `{ kind, source, screen, edge, x, y, width, height, radius, bandX, bandWidth, bandY, bandHeight }` in `GlobalStates.irisBubbleCard`.
- **Morphing Surface Execution:**
  - `modules/iris/stage/IrisStage.qml`: Instantiates `IrisMorphSurface { id: card; open: root.cardOpen; origin: root.cardAnchor; ... }`.
  - `modules/iris/components/IrisMorphSurface.qml`: Leverages `IrisSpring.qml` with cubic-bezier transition curves `[0.16, 1.0, 0.3, 1.0]` to animate geometry (`x, y, width, height, radius`) continuously from the exact trigger bounds.
  - **Interaction Defect Resolution:** The originating trigger element in the bar is flagged via `GlobalStates.irisBubbleCard.source` and visually absorbed directly into the growing surface rather than remaining visible as a duplicate static button behind it.
  - **Dismissal & Reversal:** Dismissal via outside tap, Escape key, or clicking the grabber handle reverses the spring transition cleanly back into the originating trigger coordinates.

### B. Top Bar & Island Chassis
- **Source Files:** `modules/iris/bar/IrisBar.qml`, `modules/iris/bar/island/IslandBarZones.qml`, `modules/iris/frame/IrisFrame.qml`.
- **Architecture:** `IrisBar.qml` instantiates `PanelWindow` on layer `WlrLayer.Top` (or `Overlay` when elevated), managing three zones: start, center (Island heart), and end.
- **Dock Support:** `modules/iris/dock/IrisDock.qml` provides the optional floating or integrated dock with app launcher pins and running task indicators.

### C. Control Center & Quick Settings
- **Source Files:** `modules/iris/control/IrisControlCenter.qml`, `IrisControlGrid.qml`, `IrisQuickPanel.qml`, `modules/iris/pieces/IrisPieces.qml`.
- **Capabilities:** Grid layout of toggles (Wi-Fi, Bluetooth, Do Not Disturb, Night Light/Hyprsunset, Game Mode, Power Profile), master sliders (volume, brightness), and deep-dive sub-surfaces.

### D. Audio Engine, Mixer, and Per-App Streams
- **Source Files:** `services/Audio.qml`, `modules/iris/stage/IrisCardContent.qml` (`soundCard`, `micCard`, `LevelCard`), `modules/iris/sidebar/IrisSidebarSection.qml` (`mixerComponent`).
- **Capabilities:** Direct PipeWire integration via `Quickshell.Services.Pipewire` (`PwObjectTracker`), reactive default sink/source tracking, physical device routing, per-app stream volume control, and mute states.

### E. Notifications & Notification History
- **Source Files:** `services/Notifications.qml`, `modules/iris/notificationPopup/IrisNotificationPopup.qml`, `modules/iris/bar/banners/IrisBanners.qml`.
- **Capabilities:** Wayland notification server implementing Freedesktop notification spec, transient popups with action buttons, inline reply, and persistent history sidebar.

### F. Application Launcher, Overview & Search
- **Source Files:** `modules/iris/palette/IrisPalette.qml`, `services/AppSearch.qml`, `services/AppCatalog.qml`, `services/AppLauncher.qml`.
- **Capabilities:** Fast fuzzy-search application launcher, categorized launcher view, math evaluator, web query shortcuts, and recent history.

### G. Settings, Appearance, Theming & Wallpaper
- **Source Files:** `modules/iris/settings/IrisSettings.qml`, `modules/iris/studio/IrisStudio.qml`, `modules/iris/settings/IrisThemes.qml`, `services/Wallpapers.qml`, `services/ThemeService.qml`, `services/MaterialThemeLoader.qml`.
- **Capabilities:** In-situ iRiS Studio customizer, theme preset switcher (Iris, Round, Angular, Contrast), Material You color extraction from wallpaper, and multi-source wallpaper browser.

### H. Lock Screen & Session Controls
- **Source Files:** `modules/iris/lock/IrisLockStage.qml`, `modules/iris/session/IrisSessionScreen.qml`, `modules/lock/Lock.qml`.
- **Capabilities:** Pam-based authentication screen with time display, battery indicator, media controls, and session power management (shutdown, restart, suspend, logout, lock).

---

## 3. Compositor Analysis & Compatibility Strategy

| Subsystem | Upstream iNiR Default | Hyprland Compatibility Strategy |
|---|---|---|
| **Compositor Detection** | `CompositorService.qml` checks `NIRI_SOCKET` and `HYPRLAND_INSTANCE_SIGNATURE` | Hyprland is already auto-detected (`isHyprland = true`, `isNiri = false`). |
| **Workspace Indicators** | `IslandBarZones.qml` checked `CompositorService.isNiri` | Thin adaptation: Enable `(CompositorService.isNiri \|\| CompositorService.isHyprland)`. Map `HyprlandData.workspaces` / `Hyprland.workspaces` and dispatch `Hyprland.dispatch("workspace " + id)`. |
| **Window Tracking** | `NiriService.windows` | `HyprlandData.qml` already contains `updateWindowList()` querying `hyprctl clients -j`. |
| **Monitors & Power** | `NiriService.powerOffMonitors()` | `CompositorService.qml` dispatches `Hyprland.dispatch("dpms off")`. |
| **Layer Namespace** | `quickshell:iris-chassis` | Coexists with `sea-shell` namespaces (`sea-shell:desktop`, `sea-shell:dock`). |
| **Typography & Glyphs** | System `Material Symbols Rounded` | Bundled `assets/fonts/MaterialSymbolsRounded.ttf` registered via `FontLoader` to ensure zero missing glyphs without package installation. |

---

## 4. Implementation & Execution Plan

1. **Step 1: Deploy Upstream Runtime Payload into `config/quickshell/reimagined/`**
   - Copy canonical runtime modules: `modules/` (including `iris/`, `common/`, `settings/`, `mediaControls/`, `closeConfirm/`, `background/`, `lock/`, `sessionScreen/`, etc.).
   - Copy canonical service layer: `services/` (including `Audio.qml`, `CompositorService.qml`, `HyprlandData.qml`, `Network.qml`, `BluetoothStatus.qml`, `Wallpapers.qml`, `ThemeService.qml`, `Notifications.qml`, etc.).
   - Copy assets: `assets/fonts/` (Inter, Rubik, Montserrat + bundled `MaterialSymbolsRounded.ttf`), `assets/icons/`.
   - Copy scripts: `scripts/` (`colors/`, `lib/`, `inir`, `hyprland/`, etc.).
   - Copy root shell entrypoints: `qmldir`, `shell.qml`, `GlobalStates.qml`, `ShellIrisPanels.qml`, `settings.qml`.
   - Copy `defaults/` with `defaults/config.json` configured for `"panelFamily": "iris"` and `"bar": { "layout": "island" }`.

2. **Step 2: Apply Thin Compatibility Layer**
   - Adapt `modules/iris/bar/island/IslandBarZones.qml` for Hyprland workspaces.
   - Register `MaterialSymbolsRounded.ttf` in `modules/iris/style/IrisStyle.qml` and `modules/common/widgets/MaterialSymbol.qml`.
   - Configure isolated config path routing in `modules/common/Directories.qml` and `Config.qml` via environment variable `INIR_CONFIG_FILE` / `NEXOS_CONFIG_FILE`.

3. **Step 3: Update Isolated Test Harness (`run-reimagined.sh`)**
   - Provide `check`, `run`, `stop`, `status` subcommands.
   - Run in isolated environment with custom config and font fallbacks.
   - Maintain PID lockfile to ensure killing the test runner never affects PID 2211 (`sea-shell`).

4. **Step 4: Validation & Quality Assurance**
   - Syntax verification via `qmllint` / `qs check`.
   - Launch verification in isolated mode.
   - Validate Island origin morphing, audio stream mixer, notifications, and settings overlay.

---

## 5. Full Upstream iNiR Replacement & Live Execution Verification

### A. Stopping Sea-Shell (Phase 1)
To ensure zero layer overlap and allow iNiR to run as the primary shell:
1. **Supervisor Process Inspection:** Located PID 2190 (`sh ~/.config/quickshell/sea-shell/sea-bar-supervisor.sh`), child shell PID 892167 (`qs -c sea-shell`), and rotator PID 2324 (`sea-wallpaper-rotate.sh`).
2. **Clean Termination:** Sent SIGTERM to PID 2190, stopped wallpaper rotation via `sea-wallpaper-rotate.sh --stop`, and confirmed zero remaining sea-shell processes.
3. **Layer Audit:** Confirmed via `quickshell list --all` ("No running instances") and `hyprctl layers` that all Sea-Shell layers (`sea-shell:desktop`, `sea-shell:dock`, `sea-bar`) completely cleared from display `eDP-1`.

### B. Upstream iNiR Payload & Source Integration (Phase 2 & 3)
- **Authoritative Upstream:** Cloned directly from `https://github.com/snowarch/iNiR` at stable release `v2.33.0` (commit `48cdcecb0f6089cfbb7019054602eab28e154b3b`).
- **Complete Replacement:** Removed all obsolete custom prototype files (`FloatingIsland.qml`, `SpatialCapsuleSurface.qml`, `TopBar.qml`, `OriginExpansion.qml`, `Tokens.qml`, `MotionEngine.qml`, etc.).
- **Canonical Architecture:** Integrated genuine iNiR runtime modules into `~/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/`:
  - `modules/iris/`: Genuine Island / iRiS stage, chassis, morphing surfaces, bubble cards, control center, palette, and style.
  - `modules/common/`: Common widgets, dialogs, toasts, and styling.
  - `modules/settings/`: Comprehensive shell configuration and appearance customizer.
  - `services/`: Canonical hardware and compositor services (`Audio.qml`, `CompositorService.qml`, `HyprlandData.qml`, `Brightness.qml`, `Network.qml`, `Battery.qml`, `Wallpapers.qml`, etc.).
  - `assets/`: Bundled fonts (`MaterialSymbolsRounded.ttf`, `Inter`, `Rubik`, `Montserrat`) and icons.
  - `defaults/config.json`: Configured with `"panelFamily": "iris"` and enabled panels: `irisBar`, `irisPalette`, `irisControlCenter`, `irisNotificationPopup`, `irisOnScreenDisplay`, `irisSessionScreen`, `irisLock`, `irisPolkit`.

### C. Live Execution & Compositor Verification
The shell is actively running in background daemon mode:
- **Instance ID:** `jzijvz9smt`
- **Shell ID:** `inir`
- **Process ID:** Verified running via `quickshell list --all`
- **Wayland Connection:** `wayland/wayland-1`
- **Hyprland Layers (`hyprctl layers` on `eDP-1`):**
  - `quickshell:iris-chassis` (fullscreen spatial chassis)
  - `quickshell:iris-wave` (top, bottom, left, right edge waves)
  - `quickshell:iris-reserve-top`, `iris-reserve-bottom`, `iris-reserve-left`, `iris-reserve-right` (strut reserves)

### D. Upstream IPC & Interaction Model Validation
Every primary interaction subsystem was tested and verified via live Quickshell IPC calls:

| IPC Command | Action Verified | Live Output / State |
|---|---|---|
| `quickshell ipc -p config/quickshell/reimagined call iris status` | Initial resting state | `{"islandExpanded":false,"islandShape":"clock","accent":"blue",...}` |
| `quickshell ipc -p config/quickshell/reimagined call iris toggle` | Morph Island to expanded surface | `{"islandExpanded":true,"islandShape":"expanded","islandPage":"desktop",...}` |
| `quickshell ipc -p config/quickshell/reimagined call iris toggle` | Dismiss expanded surface | `{"islandExpanded":false,"islandShape":"clock",...}` |
| `quickshell ipc -p config/quickshell/reimagined call iris controlCenter open` | Open Control Center | `{"islandExpanded":true,"islandShape":"expanded","islandPage":"controls","controlCenter":true,...}` |
| `quickshell ipc -p config/quickshell/reimagined call iris bubbleCard sound` | Open sound card surface | `{"bubbleCard":"sound",...}` (shows PipeWire sinks, volume sliders, per-app streams) |
| `quickshell ipc -p config/quickshell/reimagined call brightness status` | Read hardware backlight | `eDP-1 intel_backlight: 70%, hardware 280/400` |
| `quickshell ipc -p config/quickshell/reimagined call network status` | Read live Wi-Fi telemetry | `{"online":true,"wifi":"connected","name":"OnePlus 13s 1"}` |
| `quickshell ipc -p config/quickshell/reimagined call battery status` | Read live battery level | `34% charging` |

### E. Operational Shell Management Commands
The shell includes a streamlined launcher at the root of the repository (`./launch.sh`):

- **Start shell in background:**
  ```bash
  ./launch.sh run
  ```
- **Check shell status:**
  ```bash
  ./launch.sh status
  ```
- **Stop shell:**
  ```bash
  ./launch.sh stop
  ```
- **Open Settings / Appearance Customizer:**
  ```bash
  ./launch.sh settings
  ```
- **Inspect live logs:**
  ```bash
  tail -f /tmp/nexos-shell.log
  ```

### F. Sea-Shell Fallback & Rollback Instructions
The Sea-Shell configuration at `~/.config/quickshell/sea-shell/` was completely untouched and preserved. To restore Sea-Shell at any time:
1. Stop iNiR:
   ```bash
   ~/hari-dev0x/Projects/NexOS/launch.sh stop
   ```
2. Relaunch Sea-Shell supervisor:
   ```bash
   nohup sh ~/.config/quickshell/sea-shell/sea-bar-supervisor.sh >/dev/null 2>&1 &
   ```

---

## 6. Resolution of System and Application Icons

### A. Root Cause Analysis
During initial launch testing, `/tmp/nexos-shell.log` contained repeated icon-resolution errors:
- `Could not load icon "nm-signal-75"`
- `Could not load icon "nm-signal-100"`
- `Could not load icon "image-missing"`
- `Could not load icon "application-x-executable"`
- `Could not load icon "org.gnome.Calculator"`
- `Could not load icon "firefox"`
- `Could not load icon "firefox?fallback=audio-x-generic"`

**Detailed Diagnostic Findings:**
1. **Upstream Theme Assumption:** Upstream iNiR hardcodes `WhiteSur-dark` as its default canonical icon theme in `defaults/config.json` (`"iconTheme": "WhiteSur-dark"`) and `modules/common/Config.qml` (`property string iconTheme: "WhiteSur-dark"`).
2. **System Propagation:** `services/IconThemeService.qml` propagates this setting on startup via `gsettings set org.gnome.desktop.interface icon-theme WhiteSur-dark`, `~/.config/kdeglobals`, `~/.config/gtk-3.0/settings.ini`, and `~/.config/qt6ct/qt6ct.conf`.
3. **Missing On-Disk Theme Assets:** On CachyOS, `WhiteSur-dark` was not installed in `/usr/share/icons` or `~/.local/share/icons`. Upstream iNiR relies on its bundled installer (`sdata/lib/package-installers.sh: install-whitesur-icons()`) to fetch and install the theme into `~/.local/share/icons/WhiteSur-dark`.
4. **Qt / Quickshell Icon Lookup Failure:** With `QT_QPA_PLATFORMTHEME=gtk3`, Qt6 read `themeName="WhiteSur-dark"`. Because the directory did not exist, Qt could not parse its `index.theme` to resolve inheritance (`Inherits=hicolor,breeze`). With no theme directory and broken inheritance, Qt failed every `QIcon::fromTheme()` lookup requested by Quickshell's `image://icon/` image provider.

### B. Independent Host & Qt Testing
Using an independent PySide6 / Qt6 probe across installed themes:
- Under uninstalled `WhiteSur-dark`:
  `hasThemeIcon("firefox") == False`, `hasThemeIcon("nm-signal-75") == False`, `hasThemeIcon("org.gnome.Calculator") == False`.
- Under installed `Papirus-Dark` or `breeze-dark`:
  All returned `True`.

### C. Implementation & Fix
In strict alignment with upstream iNiR's intended environment:
1. Deployed the authoritative upstream reference `WhiteSur-icon-theme` into `~/.local/share/icons/` using upstream's official installation method (`install.sh -d ~/.local/share/icons -t default` with `gtk-update-icon-cache`).
2. Generated complete `WhiteSur`, `WhiteSur-dark`, and `WhiteSur-light` directories with valid `index.theme` files (`Inherits=hicolor,breeze`).
3. Verified complete icon mapping:
   - Panel signal icons: `nm-signal-75.svg`, `nm-signal-100.svg`, `nm-signal-*-symbolic.svg`.
   - MIME & fallback: `application-x-executable.svg`, `image-missing.svg`.
   - Desktop application symlinks: `calc.svg -> org.gnome.Calculator.svg`, `firefox.svg`.

### D. Verification & Log Audit
1. **PySide6 / Qt6 Probe:**
   Confirmed `QIcon.themeName() == "WhiteSur-dark"`, with `hasThemeIcon` returning `True` for `firefox`, `nm-signal-75`, `nm-signal-100`, `image-missing`, `org.gnome.Calculator`, and `application-x-executable`.
2. **Quickshell Restart:**
   Restarted NexOS shell cleanly via `./launch.sh stop && ./launch.sh run` (PID `926475`).
3. **Log Audit:**
   Inspected `/tmp/nexos-shell.log` and the active binary session log (`/run/user/1000/quickshell/by-id/fvuj5iasmt/log.qslog`).
   **Result:** Exact match for `could not load icon` returned `0` occurrences.
4. **Interactive UI Verification:**
   Triggered Island expansion, Control Center toggles, application launcher/palette, and PipeWire sound bubble cards via IPC.
   **Result:** Zero icon load failures logged across all active surfaces.

---

## VIII. Phase 3 — Complete Upstream iNiR Ecosystem Integration & Optional Extras Staging

### A. Architectural Scope & Target Revision
The goal of Phase 3 is the integration of the **entire upstream iNiR repository ecosystem**, including its command-line utilities, maintenance systems, migrations framework, documentation, Python virtual environment, and optional extras, while preserving runtime compatibility with CachyOS + Hyprland and zero disruption to the user's desktop.

- **Authoritative Upstream:** `https://github.com/snowarch/iNiR`
- **Pinned Upstream Revision:** Version `2.33.0`, Commit `48cdcecb0f6089cfbb7019054602eab28e154b3b`
- **Local Project Path:** `~/hari-dev0x/Projects/NexOS`
- **Working Branch:** `NexOS-reimagined`
- **Safety Boundary:** `~/.config/quickshell/sea-shell` left 100% untouched; SDDM and greeter configurations strictly untouched; zero unapproved git commits or pushes.

---

### B. Tree Synchronization & Structural Layout
All upstream trees, tools, manifests, and documentation have been synced directly into `config/quickshell/reimagined/`, making the shell directory a self-contained upstream root:

| Component / Subdirectory | Contents & Role | Status |
|---|---|---|
| `config/quickshell/reimagined/setup` | Complete upstream interactive TUI installer and lifecycle tool (127 KB executable) | Integrated & Verified |
| `config/quickshell/reimagined/scripts/inir` | Complete upstream CLI management script with full IPC registry | Integrated & Verified |
| `config/quickshell/reimagined/sdata/` | Upstream package manifests, distro profiles, migrations (44 scripts), UV files, and helpers | Integrated & Verified |
| `config/quickshell/reimagined/dots/` | Upstream dotfile templates and configuration drops (`dots/sddm/pixel/`, etc.) | Integrated & Staged |
| `config/quickshell/reimagined/docs/` | Complete upstream documentation (`INSTALL.md`, `IPC.md`, `NIRI.md`, `HYPRLAND.md`, etc.) | Integrated & Verified |
| `config/quickshell/reimagined/version.json` | Valid version tracking metadata (`v2.33.0`, commit `48cdcecb...`) | Active |
| `config/quickshell/reimagined/VERSION` | Version indicator string (`2.33.0`) | Active |
| `UPSTREAM.md` | Comprehensive integration reference and upstream tracking log | Active |
| `./inir` | Root forwarder wrapper calling `config/quickshell/reimagined/scripts/inir` | Active & Executable |
| `./setup` | Root forwarder wrapper calling `config/quickshell/reimagined/setup` | Active & Executable |
| `./launch.sh` | NexOS isolated shell lifecycle runner (start, stop, status, logs) | Active & Executable |

---

### C. Python UV Virtual Environment (`~/.local/state/quickshell/.venv`)
Upstream iNiR relies on an isolated Python virtual environment for color extraction, Material You dynamic theming, media operations, and YouTube Music scraping:

1. **Virtual Environment Creation:** Initialized via `uv venv ~/.local/state/quickshell/.venv` using CPython 3.10.
2. **Package Deployment:** Installed all 32 upstream packages defined in `sdata/uv/requirements.txt`:
   - `materialyoucolor==3.0.4`, `material-color-utilities==0.2.4`, `kde-material-you-colors==2.2.0`
   - `opencv-contrib-python==5.0.0.93`, `pillow==12.3.0`, `numpy==2.2.6`
   - `psutil==7.2.2`, `loguru==0.7.3`, `click==8.5.0`
   - `pygobject==3.58.1`, `pycairo==1.29.2`, `dbus-python==1.5.0`
   - `yt-dlp==2026.8.19`, `ytmusicapi==1.12.3`, `websockets==16.1.1`
3. **Verification:** Verified via `./inir doctor` Step 13 (`✓ Python packages OK`, `✓ YT Music JS runtime OK`).

---

### D. Staging of Optional Extras

All upstream optional extras have been staged under `extras/` and prepared for user discovery without auto-enabling intrusive system components:

1. **`extras/iNiR-Walls/` (Official Wallpaper Pack):**
   - Cloned official `https://github.com/snowarch/iNiR-Walls.git` repository (632.5 MiB).
   - Contains all 148 high-resolution curated wallpapers.
   - Synced to `~/Pictures/Wallpapers/` via non-destructive `cp -n`, preserving all existing user wallpapers (expanding the collection from 31 to 175 wallpapers).
2. **`extras/yet-another-monochrome-icon-set/` (YAMIS Icon Theme):**
   - Cloned `https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set.git` (~23 MiB).
   - Symlinked to `~/.local/share/icons/yet-another-monochrome-icon-set` for instant availability in iNiR Settings → Appearance → Icon Theme.
3. **`extras/inir-mascot/` (Kira Companion Art Pack):**
   - Downloaded and verified upstream release bundle `inir-mascot-pack.tar.gz` (`v3`, 33.4 MB).
   - Extracted 354 verified pose PNGs and looping GIFs into `extras/inir-mascot/extracted/` and `config/quickshell/reimagined/assets/images/mascot/`.
   - Verified asset tree SHA-256: `85f8c2671aafc161d21bd59176bfc9b4eed02c6d983b655bcfac61c354df4398`.
   - Recorded state in `~/.local/state/inir/mascot-pack-state.json`.
   - **Safety / Policy Compliance:** The mascot companion remains **disabled by default** in settings (`enabled: false`), unlocking the UI toggle for the user without intrusive presence.
4. **`extras/ii-pixel-sddm/` (SDDM Theme):**
   - Staged the full `ii-pixel-sddm` theme QML components, shaders, fonts, and installer script.
   - Authored `extras/ii-pixel-sddm/README.md` detailing manual inspection/testing commands (`sddm-greeter-qt6 --test-mode`).
   - **Safety Boundary:** No display manager or `/etc/sddm.conf.d/` modifications were executed.

---

### E. Diagnostic & IPC Verification

1. **`./inir status` Output:**
   - Reports installed version: `2.33.0`, commit: `48cdcecb0f6089cfbb7019054602eab28e154b3b`.
   - Distro: `NexOS`, Compositor: `hyprland 0.56.2`, Session: `wayland-1`.
   - Runtime path: `/home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined`.
   - Shell status: `✓ Shell is running`.
   - Boot timings: QML evaluated 0ms, Config ready 39ms, Bar visible 367ms, Services warm 913ms.
2. **`./inir doctor` Output:**
   - 22 checks passed, 4 auto-fixed (fonts cached, user service unit created, environment variables registered in shell profiles).
   - Python packages, Quickshell/Qt ABI, theme colors, critical files, and wallpaper health all verified clean.
3. **iRiS IPC Verification:**
   - `./inir iris status` returns complete JSON state payload:
     `{"islandExpanded":false,"islandShape":"idle","islandPage":"","accent":"blue","preset":"soft","bubbleCard":"","utility":"tray","trayItems":1,"dockShown":false,"controlCenter":false,"spotlight":false,"orbit":false,...}`
   - Dynamic IPC toggle verified: `./inir iris spotlight "hello"` sets `.spotlight: true`; `./inir iris spotlightClose` cleanly closes and sets `.spotlight: false`.
4. **Daemon Stability & Logs:**
   - Shell daemon running smoothly under PID `62311` on `wayland-1`.
   - Zero icon errors logged in `/tmp/nexos-shell.log`.

---

## Phase 3 — Permanent Default Shell Implementation & Lifecycle Management

### 1. Mission & Scope
Transition NexOS (iNiR v2.33.0) from a tested standalone prototype into the **single, persistent, default desktop shell** for the user session on CachyOS + Hyprland, establishing an authoritative startup mechanism, supervisor crash backoff, Hyprland keybind integration, and complete Sea-Shell rollback safety.

### 2. Audit of Startup Paths & Elimination of Duplication
- **Audited Mechanisms:**
  - `systemd/user/inir.service`: Inspected; verified static and inactive with hard dependencies on `niri.service` (`Requisite=niri.service`), making it invalid for Hyprland.
  - `~/.config/hypr/hyprland.lua`: Identified as the single authoritative autostart hook used by this system via `hl.on("hyprland.start", ...)`.
  - Prior Sea-Shell autostart: Spanned `sea-bar-supervisor.sh`, `sea-wallpaper-restore.sh`, and `dofile` inclusions for `sea.lua` and `keybinds.lua`.
- **Sea-Shell Termination & Preservation:**
  - Gracefully terminated Sea-Shell supervisor (`PID 2151`), wallpaper rotation daemon (`PID 2317`), apply loop (`PID 2494`), and `qs -c sea-shell` (`PID 5313`).
  - Completely preserved `~/.config/quickshell/sea-shell/` and `~/.config/hypr/sea-shell/` files without deletion or damage.
  - Created pre-migration backups:
    - `~/.config/hypr/hyprland.lua.backup-before-inir`
    - `~/.config/hypr/hyprland/keybinds.lua.backup-before-inir`

### 3. Supervisor Architecture (`run-reimagined.sh`)
Implemented a dedicated daemon supervisor mode within `config/quickshell/reimagined/run-reimagined.sh`, invoked directly by `./launch.sh`:
- **Single-Instance Locking:** Uses `flock` on `/tmp/nexos-supervisor.lock` with PID tracking in `/tmp/nexos-supervisor.pid` and `/tmp/nexos-shell.pid`.
- **Crash Loop Backoff / Rate Limiting:**
  - Tracks crash timestamps in an array.
  - If more than 5 unexpected crashes occur within 10 seconds, the supervisor immediately aborts respawning, logs `[NexOS Supervisor] ERROR: Shell crashed 5 times within 10s. Halting respawn to avoid lockup.` to `/tmp/nexos-shell.log`, and alerts the user via `notify-send -u critical`.
- **Graceful Termination Traps:** Intercepts `SIGTERM`, `SIGINT`, and `EXIT`, ensuring that killing the supervisor terminates the child Quickshell instance and purges PID files.
- **Idempotency:** Calling `./launch.sh run` while the shell is running confirms running PIDs and exits 0 without spawning duplicate instances.
- **Clean Restart:** `./launch.sh restart` signals the existing supervisor, waits for Quickshell exit, and launches a fresh supervised daemon.

### 4. Authoritative Hyprland Autostart & Keybindings
1. **`~/.config/hypr/hyprland.lua`:**
   - Replaced Sea-Shell `dofile` and supervisor lines with:
     ```lua
     -- >>> NexOS Shell >>>
     -- Authoritative shell: NexOS (iNiR v2.33.0) managed via ~/hari-dev0x/Projects/NexOS/launch.sh
     hl.on("hyprland.start", function()
         hl.exec_cmd("/home/hari/hari-dev0x/Projects/NexOS/launch.sh run")
         hl.exec_cmd("command -v hypridle >/dev/null && exec hypridle")
         hl.exec_cmd("[ -x /usr/lib/hyprpolkitagent/hyprpolkitagent ] && exec /usr/lib/hyprpolkitagent/hyprpolkitagent")
     end)
     -- <<< NexOS Shell <<<
     ```
2. **`~/.config/hypr/hyprland/keybinds.lua`:**
   - Updated launcher, settings, session, utility, and restart bindings to call NexOS tools:
     - `SUPER + Space`: `/home/hari/hari-dev0x/Projects/NexOS/inir overview toggle` (Spotlight / App search)
     - `SUPER + S`: `/home/hari/hari-dev0x/Projects/NexOS/inir settings` (Central settings)
     - `SUPER + D`: `/home/hari/hari-dev0x/Projects/NexOS/inir iris controlCenter toggle` (Control center)
     - `SUPER + Escape`: `/home/hari/hari-dev0x/Projects/NexOS/inir session toggle` (Session / power menu)
     - `SUPER + V`: `/home/hari/hari-dev0x/Projects/NexOS/inir clipboard toggle` (Clipboard history)
     - `SUPER + T`: `kitty` (Terminal emulator)
     - `Print`: `/home/hari/hari-dev0x/Projects/NexOS/inir region screenshot` (Instant screenshot)
     - `SUPER + SHIFT + S`: `/home/hari/hari-dev0x/Projects/NexOS/inir region menu` (Region snip toolbar)
     - `SUPER + ALT + R`: `/home/hari/hari-dev0x/Projects/NexOS/inir region record` (Screen recording toggle)
     - `SUPER + SHIFT + C`: `hyprpicker -a` (Color picker)
     - `CTRL + SUPER + SHIFT + R`: `/home/hari/hari-dev0x/Projects/NexOS/launch.sh restart` (Supervisor restart)

### 5. Verification & Validation Results
- **Active Instance Audit:** `quickshell list --all` confirms single instance `inir` (PID `62311`) running `/home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined/shell.qml` on `wayland-1`.
- **Restart Verification:** `./launch.sh restart` stops existing supervisor/shell and spawns a clean replacement with 0 orphaned sockets or processes.
- **Crash Recovery Verification:** Tested by sending `kill -9` to Quickshell process; supervisor recovered and respawned shell within 1 second.
- **IPC Verification:** Tested `inir overview toggle`, `inir iris spotlight ""`, `inir iris controlCenter toggle`, `inir session toggle`, `inir clipboard toggle`, and `inir region menu` with 100% success.
- **Zero Icon Errors:** Verified in `/tmp/nexos-shell.log` with 0 icon or layout errors.

---

## Phase 4 — Multi-Session Isolation & Niri Keybinding Translation

### 1. Mission & Objectives
Audit the shell supervisor and process lifecycle to ensure complete session-awareness between the active Hyprland session and any current or future Niri graphical session. Translate all active NexOS keybindings into valid Niri KDL syntax while preserving Hyprland's authoritative startup hook and runtime environment.

### 2. Multi-Session Locking & PID Tracking Audit
- **Vulnerabilities Identified in Initial Supervisor:**
  1. Lock file collision: Hardcoded lock path `${XDG_RUNTIME_DIR}/nexos-shell-supervisor.lock` was shared across all Wayland displays in the user session. A Niri session would be blocked from launching if Hyprland was running.
  2. PID file collision: `/tmp/nexos-shell-supervisor.pid` and `/tmp/nexos-shell.pid` lacked session tags; running `launch.sh run` from Niri would falsely detect Hyprland's supervisor as its own and exit without launching.
  3. Cross-session termination: Running `launch.sh stop` from Niri would read Hyprland's PID file and terminate the Hyprland shell.
- **Architectural Fix Implemented (`run-reimagined.sh`):**
  - **Dynamic Session Tagging:** Created `get_session_id()` deriving `<compositor>-<wayland-display>` (e.g. `hyprland-wayland-1`, `niri-wayland-0`).
  - **Isolated Runtime Paths:** Moved files to `${XDG_RUNTIME_DIR}/nexos/`:
    - `supervisor-${SESSION_ID}.lock`
    - `supervisor-${SESSION_ID}.pid`
    - `shell-${SESSION_ID}.pid`
    - `/tmp/nexos-shell-${SESSION_ID}.log`
  - **Session-Aware Process Verification:** PID lookups inspect `/proc/<PID>/environ` for `WAYLAND_DISPLAY` to ensure commands never target foreign graphical sessions.
  - **Backward Compatibility:** Preserved fallback checks for `/tmp/nexos-shell.pid` and `/tmp/nexos-shell-supervisor.pid` so the active Hyprland supervisor and shell remain 100% operational without restart.

### 3. Niri Session Configuration & Translated Keybindings
- **Staged Configuration:** Initialized `~/.config/niri/` with modular KDL fragments from `defaults/niri/`.
- **Startup Configuration (`~/.config/niri/config.d/50-startup.kdl`):**
  - Configured `spawn-at-startup "/home/hari/hari-dev0x/Projects/NexOS/launch.sh" "run"`.
  - Preserved `inir.service` disabled/inactive state (until systemd unit dependencies are formally verified for an active Niri session).
- **Translated Keybindings (`~/.config/niri/config.d/70-binds.kdl`):**
  - `Mod+Space repeat=false { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "overview" "toggle"; }`
  - `Mod+S { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "settings"; }`
  - `Mod+D { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "iris" "controlCenter" "toggle"; }`
  - `Mod+Escape { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "session" "toggle"; }`
  - `Mod+V { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "clipboard" "toggle"; }`
  - `Mod+T { spawn "kitty"; }`
  - `Print { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "region" "screenshot"; }`
  - `Mod+Shift+S { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "region" "menu"; }`
  - `Mod+Alt+R { spawn "/home/hari/hari-dev0x/Projects/NexOS/inir" "region" "record"; }`
  - `Mod+Shift+C { spawn "hyprpicker" "-a"; }`
  - `Ctrl+Mod+Shift+R { spawn "/home/hari/hari-dev0x/Projects/NexOS/launch.sh" "restart"; }`
  - `Mod+Q repeat=false allow-inhibiting=false { close-window; }`
  - `Mod+Shift+F { maximize-column; }`

### 4. Verification & Safety Assurance
- **Active Hyprland Shell Integrity:**
  - `quickshell list --all` confirms instance `inir` (PID `62311`, supervisor PID `62305`) ran uninterrupted throughout all changes.
  - `./launch.sh status` confirms active status under `[hyprland-wayland-1]`.
- **Multi-Session Isolation Validated:**
  - Simulated Niri environment (`WAYLAND_DISPLAY="wayland-0" XDG_CURRENT_DESKTOP="niri" NIRI_SOCKET="..." ./launch.sh status`): accurately reported `NexOS shell is NOT running for session [niri-wayland-0]`.
  - Simulated Niri stop (`./launch.sh stop`): confirmed clean no-op without killing or signaling Hyprland's supervisor or shell.
- **Hyprland Configuration Preserved:** `~/.config/hypr/hyprland.lua` and `~/.config/hypr/hyprland/keybinds.lua` completely untouched.

---

## Phase 5 — Niri Installation, Configuration Validation & Multi-Session Hardening

### 1. Package Installation
- **Verification:** Verified absence of `niri` binary (`command -v niri` returned 1). Checked repository availability via `pacman -Ss '^niri$'`.
- **Package Installed:** Installed official CachyOS package `cachyos-extra-v3/niri 26.04-1.1` via `sudo pacman -S --noconfirm niri`.
- **Installed Version:** `niri 26.04 (8ed0da4)`.
- **Session Entry Created:** `/usr/share/wayland-sessions/niri.desktop` (executes `niri-session`).

### 2. Configuration Validation (`niri validate`) & Conflict Resolution
- **Initial Validation:** Executed `niri validate`, which parsed `~/.config/niri/config.kdl` and flagged two duplicate keybind collisions in `config.d/70-binds.kdl`:
  1. `Mod+Escape`: Bound to `toggle-keyboard-shortcuts-inhibit;` and `spawn ... inir session toggle`.
  2. `Print`: Bound to `spawn ... inir region screenshot` and native `screenshot;`.
- **Remediations Applied (backed up to `70-binds.kdl.bak`):**
  - Mapped `Mod+Shift+Escape` to `toggle-keyboard-shortcuts-inhibit;` with `allow-inhibiting=false`, preserving `Mod+Escape` for the NexOS session/power menu.
  - Commented out duplicate native `Print { screenshot; }`, allowing `Print` to invoke iNiR's integrated region screenshot tool while retaining `Ctrl+Print`, `Mod+Print`, and `Alt+Print` for native Niri capture.
- **Clean Validation:**
  ```text
  DEBUG niri_config: loaded config from "/home/hari/.config/niri/config.kdl"
  INFO niri: config is valid
  ```

### 3. Startup & Service Integration Audit (`50-startup.kdl`)
- **Polkit Agent Resolution:** Upstream iNiR provides native Polkit dialogs via Quickshell's Polkit service. Verified that `/usr/lib/hyprpolkitagent/hyprpolkitagent` was absent on disk. Updated startup fallback to probe `/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1` and `polkit-kde-authentication-agent-1` only as fallbacks when the shell is inactive.
- **Portals:** `xdg-desktop-portal` and `xdg-desktop-portal-gtk` are installed. Verified no duplicate portal daemons are launched directly from KDL startup hooks.
- **Clipboard Watchers:** Preserved `wl-paste` watchers piping to `clipboard-store.py` and `clipboard-image-store.sh`. Confirmed no duplicate clipboard instances between Hyprland and Niri.
- **iNiR Systemd Service:** Confirmed `systemctl --user status inir.service` is inactive/static. Shell startup in Niri is managed by the supervisor via `spawn-at-startup ".../launch.sh" "run"`.

### 4. Multi-Session Isolation Verification
- **Simulated Niri Session Test:**
  - Ran `WAYLAND_DISPLAY=wayland-99 NIRI_SOCKET=/run/user/1000/niri-test.sock XDG_CURRENT_DESKTOP=niri ./launch.sh status` -> returned `NexOS shell is NOT running for session [niri-wayland-99]`.
  - Ran `WAYLAND_DISPLAY=wayland-99 NIRI_SOCKET=/run/user/1000/niri-test.sock XDG_CURRENT_DESKTOP=niri ./launch.sh stop` -> clean no-op, exiting 0 without signaling other processes.
- **Hyprland Desktop Unaffected:**
  - Active shell under Hyprland (Supervisor PID `62305`, Shell PID `62311`, session `hyprland-wayland-1`) continued uninterrupted.
  - Hyprland default desktop session, SDDM theme (`nexos`), and Sea-Shell rollback backups remain intact.

---

## Phase 6 — Runtime Status Diagnosis & Resolution

### 1. Root Cause Diagnosis
When evaluating `./setup status`, the runtime path and metadata were reported as `(missing)` despite Quickshell running actively. Investigation revealed three distinct path-resolution defects:
1. **Missing Wrapper Environment Propagation:** The repository root wrapper `./inir` exported `INIR_RUNTIME_DIR` and `INIR_CONFIG_DIR`, but the root `./setup` wrapper did not export these variables before delegating to `config/quickshell/reimagined/setup`.
2. **False-Negative Runtime Shell Directory Discovery:** In `config/quickshell/reimagined/sdata/lib/versioning.sh`, the function `get_runtime_shell_dir()` tested only `INIR_RUNTIME_DIR` (if set) and hardcoded static paths (`~/.config/quickshell/inir` and `/usr/share/quickshell/inir`). It did not check:
   - Self-relative path from the library itself (`../../shell.qml`).
   - `REPO_ROOT` or subpath `REPO_ROOT/config/quickshell/reimagined`.
   - The active running Quickshell instance via `qs list --all --json` / `quickshell list --all --json`.
   - The repository path stored in `~/.config/inir/version.json` or `~/.config/illogical-impulse/version.json`.
3. **Standalone Launcher Path Resolution Defect:** When invoking `~/.local/bin/inir status`, the helper loader `source_config_path_helper()` in `scripts/inir` failed with `Unable to locate config-path helper` because:
   - `script_dir` did not resolve symlinks via `readlink -f`.
   - Helper candidates did not inspect `INIR_RUNTIME_DIR` or stored `repoPath`.
   - Subshell delegations in `run_setup_command` and `run_setup_inline` did not propagate `INIR_RUNTIME_DIR` or `INIR_CONFIG_DIR`.

### 2. Confirmation of Installation Integrity
The underlying shell was **never broken**. Quickshell has run continuously without interruption from `/home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined` (PID `137136`) under supervisor PID `137111` on `niri-wayland-1`. The failure was strictly a false-negative status diagnostic defect and launcher path discovery bug.

### 3. Modifications & Backups
All source files were backed up prior to modification:
- `config/quickshell/reimagined/sdata/lib/versioning.sh`:
  - **Backup:** `config/quickshell/reimagined/sdata/lib/versioning.sh.bak`
  - **Change:** Augmented `get_runtime_shell_dir()` to check self-relative payload root, `REPO_ROOT`, active running Quickshell instance, and stored repo path from `version.json`.
- `setup`:
  - **Backup:** `setup.bak`
  - **Change:** Added `readlink -f` resolution to `SCRIPT_DIR`; exported `INIR_RUNTIME_DIR` and `INIR_CONFIG_DIR`.
- `inir`:
  - **Backup:** `inir.bak`
  - **Change:** Added `readlink -f` resolution to `SCRIPT_DIR`.
- `config/quickshell/reimagined/scripts/inir`:
  - **Backup:** `config/quickshell/reimagined/scripts/inir.bak`
  - **Change:** Added `readlink -f` resolution; added `_inir_get_stored_repo()` fallback for helper candidate paths (`config-path.sh`, `niri-session-env.sh`, `ipc-registry.sh`); propagated `INIR_RUNTIME_DIR` and `INIR_CONFIG_DIR` during inline/subshell setup calls.
- `~/.local/bin/inir`:
  - **Backup:** `~/.local/bin/inir.bak`
  - **Change:** Synced with updated `scripts/inir` and verified execution permissions (`755`).

### 4. Validation Results
All three diagnostic entrypoints now report identical, fully verified runtime status:
- `./setup status` -> `Runtime Path: /home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined`, `✓ Shell is running`, `✓ Runtime metadata present`.
- `./inir status` -> Identical.
- `~/.local/bin/inir status` -> Identical.

### 5. Identification of Separate Warnings
In the status output:
- `⚠ 2 pending migration(s)` relates to `029-plasma-browser-integration` and `045` (optional upstream browser/integration scripts). These are harmless optional scripts and do not impact shell runtime or stability. Per strict safety instructions, no migration or state mutation was triggered.
- `⚠ Runtime payload state: unknown` occurs because the git repository root is `/home/hari/hari-dev0x/Projects/NexOS` rather than the standalone upstream iNiR repo root. This is cosmetic and expected in the unified repository layout.

---

## Phase 7 — Doctor Checkout Validation & Superproject Worktree Recognition

### 1. Mission & Scope
Remediate the false failure in `config/quickshell/reimagined/sdata/lib/doctor.sh` (`check_repo_checkout_state()`), where doctor step 3/25 ("Checking repo checkout") rejected the embedded layout because `${REPO_ROOT}/.git` was absent while the parent git repository at `/home/hari/hari-dev0x/Projects/NexOS` contained the runtime.

### 2. Implementation
- **Source file:** `config/quickshell/reimagined/sdata/lib/doctor.sh`
- **Backup:** `config/quickshell/reimagined/sdata/lib/doctor.sh.bak`
- **Minimal safe change:** Extended the git metadata check in `check_repo_checkout_state()` to accept either iNiR's own Git metadata (`[[ -e "${REPO_ROOT}/.git" ]]`) or a valid parent Git worktree containing the runtime (`git -C "$target_repo" rev-parse --is-inside-work-tree`).

### 3. Verification
- Ran `./setup doctor`.
- All 29 checks passed with 0 failures and 0 fixed (`Passed 29 Fixed 0 Failed 0 Time 6s`).
- Check 3/25 output:
  `✓ Checking repo checkout`
  `✓ Repo remote check skipped`
  `⚠ Tracking non-release branch: NexOS-reimagined`
- All background processes (Quickshell PID `137136`, supervisor PID `137111`) remained active and uninterrupted throughout.

---

## Phase 8 — NexOS Migration: iNiR Primary Environment, Shell Retirement & Hyprland Removal

### 1. Mission & Scope
Make iNiR the sole primary Quickshell environment for NexOS, retire obsolete Sea-Shell and previous spatial shell prototype configurations from active user paths, correct the optional mascot asset path resolution, and cleanly remove Hyprland while verifying Niri and iNiR stability.

### 2. Comprehensive Pre-Action Audit & Preservation
- **Active Processes & Session:**
  - Niri session PID `137012` active on `wayland-1` via `/usr/lib/sddm/sddm-helper ... --start niri-session`.
  - Quickshell iNiR process PID `137136` active under supervisor PID `137111` (`run-reimagined.sh _supervisor`).
  - Active runtime: `/home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined`.
- **Agy / Antigravity Protection:**
  - Discovered full Agy configuration at `~/.gemini/antigravity`, `~/.gemini/antigravity-cli`, and `~/.gemini/config`.
  - Verified no Agy settings, instructions, credentials, project contexts, or history were deleted or modified.
- **Git State Protection:**
  - Preserved branch `NexOS-reimagined` (HEAD at `a5b7d90`).
  - Preserved uncommitted changes, working tree modifications, and `stash@{0}` without resetting, rebasing, or committing.
- **Comprehensive Backups Created (`/home/hari/NexOS-migration-backups/20261012-inir-primary/`):**
  - `quickshell/` (`nexos/` and `sea-shell/`)
  - `niri/` (`config.kdl` and modular `config.d/`)
  - `hypr/` (`hyprland.lua`, `hypridle.conf`, `hyprlock.conf`, etc.)
  - `inir_config/` and `inir_state/`
  - `gemini_agy/` (Agy configuration and settings)
  - `git_diff_working_tree.patch`, `git_status_porcelain.txt`, `git_stash_0.patch`

### 3. Making iNiR Primary & Resolving Mascot Assets
- **Primary Shell Path Resolution:**
  - Established canonical symlink `~/.config/quickshell/inir` -> `/home/hari/hari-dev0x/Projects/NexOS/config/quickshell/reimagined`.
  - Updated `config/quickshell/reimagined/sdata/lib/extras.sh` (with backup `extras.sh.bak`) so that `extras_mascot_helper()`, `extras_refresh_mascot_pack_on_update()`, and `extras_install_mascot_pack()` resolve the runtime shell directory via `INIR_RUNTIME_DIR` or `get_runtime_shell_dir()` dynamically, falling back to `~/.config/quickshell/inir`.
  - Validated that the 354 mascot pack assets match the state hash `85f8c2671aafc161d21bd59176bfc9b4eed02c6d983b655bcfac61c354df4398` perfectly.
- **Obsolete Shell Retirement:**
  - Verified with `lsof` and grep audits that no active process, Niri config, or systemd service relies on `~/.config/quickshell/sea-shell` or `~/.config/quickshell/nexos`.
  - Retired `sea-shell` and `nexos` from `~/.config/quickshell/` by moving them into the safe recovery repository at `/home/hari/NexOS-migration-backups/20261012-inir-primary/retired-shells/`.
  - `~/.config/quickshell/` now points cleanly and solely to `inir`.

### 4. Controlled Hyprland Removal
- **Pre-removal Dependency Analysis:**
  - Verified that `niri` uses `xdg-desktop-portal-gtk` for its portal implementation, and does not require Hyprland.
  - Verified that critical tools like `hyprpicker` (used by Niri shortcut `Mod+Shift+C` and iNiR color scripts) and `brightnessctl` are preserved.
  - Determined that removing `hyprland`, `cachyos-hypr-noctalia`, `hyprshade`, and `xdg-desktop-portal-hyprland` removes only genuinely obsolete Hyprland components (91.90 MiB) without impacting desktop applications or shared libraries.
- **Removal Execution:**
  - Safely uninstalled `hyprland`, `cachyos-hypr-noctalia`, `hyprshade`, and `xdg-desktop-portal-hyprland` via `pacman -R --noconfirm`.
  - Verified `/usr/share/wayland-sessions/` now retains `niri.desktop` and `plasma.desktop`. SDDM session entry into Niri remains fully intact.

### 5. Final Verification
- **Doctor Check:** `./setup doctor` passed all 29 checks with 0 failures (`Passed 29 Fixed 0 Failed 0`).
- **Runtime & Supervisor:** Quickshell PID `137136` under supervisor PID `137111` remained continuously operational and healthy.
- **IPC Validation:** `./inir brightness status` and `~/.local/bin/inir brightness status` responded with verified hardware backlight status.
- **Rollback Documentation:** Comprehensive rollback procedure documented at `/home/hari/NexOS-migration-backups/20261012-inir-primary/ROLLBACK.md`.
