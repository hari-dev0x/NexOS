# Upstream & Third-Party Integration

## 1. Upstream Foundations & Lineage

**NexUI** is developed and maintained by **Harinarayanan B. S.** under the **GNU General Public License v3.0 (GPL-3.0)**. It builds upon foundational open-source desktop shell projects:

1. **iNiR Base:**
   - **Author:** [snowarch](https://github.com/snowarch)
   - **Repository:** [https://github.com/snowarch/iNiR](https://github.com/snowarch/iNiR)
   - **License:** GNU General Public License v3.0 (GPL-3.0)
   - **Pinned Version:** `v2.33.0` (commit `48cdcecb0f6089cfbb7019054602eab28e154b3b`)

2. **illogical-impulse Base:**
   - **Author:** [end-4](https://github.com/end-4)
   - **Repository:** [https://github.com/end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
   - **License:** GNU General Public License v3.0 (GPL-3.0)

3. **Impasto Top Bar Components:**
   - **Author:** Andreu Massanet
   - **Repository:** [https://github.com/andreumassanet/impasto](https://github.com/andreumassanet/impasto)
   - **License:** GNU General Public License v3.0 (GPL-3.0)

---

## 2. Licensing Compliance (GPL-3.0)

NexUI complies strictly with the GNU General Public License v3.0 (GPL-3.0):
- All original notices, disclaimers, and copyright attributions to snowarch, end-4, and Andreu Massanet are preserved.
- Full source code for all modifications is distributed publicly in accordance with GPL-3.0 Section 4 and Section 5.
- The complete terms of the license are provided in [`LICENSE`](LICENSE).

---

## 3. Directory Structure & Upstream Mapping

| Path | Purpose |
|---|---|
| `config/quickshell/reimagined/` | Upstream shell core, modules, and QML services |
| `config/quickshell/reimagined/shell.qml` | Shell root entry point |
| `config/quickshell/reimagined/setup` | Upstream interactive installer and lifecycle tool |
| `config/quickshell/reimagined/scripts/inir` | Upstream CLI management tool |
| `config/quickshell/reimagined/sdata/` | System packages, migrations, library scripts, and UV manifests |
| `config/quickshell/reimagined/dots/` | Dotfile templates (including SDDM pixel theme) |
| `config/quickshell/reimagined/docs/` | Upstream reference documentation and IPC specifications |
| `extras/` | Staged optional packs (Wallpapers, YAMIS icons, Kira mascot, SDDM theme) |
| `./launch.sh` | NexUI isolated shell lifecycle supervisor (start, stop, restart, status, logs) |
| `./nexui` | Root executable CLI for NexUI desktop management |
| `./inir` | Backward-compatibility symlink calling shell CLI management |
| `./setup` | Root executable calling shell setup engine |

---

## 4. Compositor & Environment Adaptations

1. **Target Compositor: Niri on CachyOS**
   - NexUI is primarily targeted and optimized for the **Niri** scrollable-tiling Wayland compositor.
   - Wayland layer-shell rules, horizontal ribbon window tracking, and Niri IPC integration are active.
   - Compatibility layers for Hyprland remain intact for multi-compositor fallback environments.
2. **Icon & Asset Resolution**
   - Standard XDG system themes (`breeze`, `breeze-dark`, `Papirus`, `Adwaita`, `hicolor`) are dynamically mapped and resolved.
   - Bundled fonts (`Inter`, `Rubik`, `Oxanium`, `Material Symbols Rounded`) load reliably via QML `FontLoader`.
3. **Rollback & Safety**
   - Checkpoints and timestamped backups are generated prior to file modifications.
   - Display managers and user sessions remain protected against unrecoverable states.

---

## 5. Maintenance & Diagnostics

```bash
# Check shell uptime, versions, and system status
./nexui status

# Run full health checks on dependencies and environment
./nexui doctor

# Inspect live shell output log
./nexui logs

# Check systemd user service status
systemctl --user status nexui.service
```
