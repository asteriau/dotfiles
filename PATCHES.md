# Local patches to vendored files

Upstream: end-4/dots-hyprland at the commit in `UPSTREAM`; `VENDORED` maps each upstream path to its location here. `home/quickshell/ii` and `system/programs/hyprland` are a fork of that commit: the motion pass below touches dozens of files, so upstream fixes in those trees are cherry-picked by hand (`git diff old new -- <upstream path> | git apply -3 --directory=<local path>` per file) rather than applied wholesale. Everything else vendored is byte-identical to upstream, and the table lists the Nix-driven patches that still keep upstream defaults.

| file | change |
|---|---|
| `home/quickshell/ii/services/LatexRenderer.qml` | `microtexBinaryDir` from `$MICROTEX_DIR`, upstream default kept |
| `home/quickshell/ii/services/HyprlandXkb.qml` | `baseLayoutFilePath` from `$ILLOGICAL_IMPULSE_XKB_RULES`, default kept |
| `home/quickshell/ii/services/Audio.qml` | sounds dir from `$ILLOGICAL_IMPULSE_SOUNDS_DIR`, default kept |
| `home/quickshell/ii/services/Emojis.qml` | emoji script path is `/etc/xdg/hypr/hyprland/scripts/fuzzel-emoji.sh` |
| `home/quickshell/ii/modules/common/Config.qml` | default `volumeMixer` uses `/etc/xdg/hypr/hyprland/scripts/launch_first_available.sh` |
| `home/quickshell/ii/scripts/colors/generate_colors_material.py` | `primary_paletteKeyColor` → `primaryPaletteKeyColor` (nixpkgs ships materialyoucolor 3.x, which renamed the attribute) |
| `system/programs/hyprland/hyprland.lua` | `custom/*`, `monitors`, `workspaces` loaded with `require(<absolute path>)` (tracked by Hyprland for auto-reload) from `~/.config/hypr`; matugen `colors.lua` and the settings app's `shellOverrides/main.lua` loaded likewise with a file-exists guard, shipped defaults as fallback |
| `system/programs/hyprland/hyprland/general.lua` | `decoration.shadow.render_power` 10 → 4 (the pinned Hyprland rejects values above 4) |
| `system/programs/hyprland/hyprland/env.lua` | removed `XDG_DATA_DIRS` and `ILLOGICAL_IMPULSE_VIRTUAL_ENV` lines |
| `system/programs/hyprland/hyprland/execs.lua` | removed `qs -c`, geoclue agent and `hypridle` exec lines (services here) |
| `system/programs/hyprland/hyprland/keybinds.lua` | restart-shell bind runs `systemctl --user restart quickshell`; `custom/variables.lua` via `require(<absolute path>)` (tracked by Hyprland for auto-reload); scripts dir is `/etc/xdg/hypr/hyprland/scripts` |
| `system/programs/hyprland/hyprland/variables.lua` | scripts dir is `/etc/xdg/hypr/hyprland/scripts` |
| `home/quickshell/ii/modules/common/widgets/shapes/` | git submodule flattened to plain files (same commit) |

## Motion fork

Spec: `docs/superpowers/specs/2026-10-21-material-motion-design.md`. In summary:

- `modules/common/Appearance.qml`: `animation` is the Material 3 Expressive token set (`spatialFast/Default/Slow`, `effectsFast/Default/Slow`, `enter`, `exit`, `reveal`); upstream names are aliases, `elementResize` now means `spatialDefault`.
- `system/programs/hyprland/hyprland/general.lua`, `rules.lua`: windows, layers, fades and workspaces on the expressive spatial and effects curves with accelerate exits; `menu_decel`, `menu_accel`, `stall` removed; OSD and media controls are `no_anim` (the shell animates them).
- New `modules/common/widgets/RevealSurface.qml` and `RevealGate.qml`; used by overview, session screen, OSD, media controls, polkit, tooltips.
- `StyledListView` add/remove on effects, enter and exit tokens.
- Token re-points across bars, dock, notifications, overview, sidebars and common widgets: spatial curves for position/size/shape/rotation, effects for colour/opacity. `Revealer` and `WindowDialog` use the `reveal` helper; `Stopwatch` has the same first-apply guard as `NavigationRailButton`.
