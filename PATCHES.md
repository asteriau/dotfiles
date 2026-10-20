# Local patches to vendored files

Upstream: end-4/dots-hyprland at the commit in `UPSTREAM`; `VENDORED` maps each upstream path to its location here. Every other vendored file is byte-identical to upstream. When applying an upstream diff, conflicts can only occur here.

| file | change |
|---|---|
| `home/quickshell/ii/services/LatexRenderer.qml` | `microtexBinaryDir` from `$MICROTEX_DIR`, upstream default kept |
| `home/quickshell/ii/services/HyprlandXkb.qml` | `baseLayoutFilePath` from `$ILLOGICAL_IMPULSE_XKB_RULES`, default kept |
| `home/quickshell/ii/services/Audio.qml` | sounds dir from `$ILLOGICAL_IMPULSE_SOUNDS_DIR`, default kept |
| `home/quickshell/ii/services/Emojis.qml` | emoji script path is `/etc/xdg/hypr/hyprland/scripts/fuzzel-emoji.sh` |
| `home/quickshell/ii/modules/common/Config.qml` | default `volumeMixer` uses `/etc/xdg/hypr/hyprland/scripts/launch_first_available.sh` |
| `system/programs/hyprland/hyprland.lua` | `custom/*`, `monitors`, `workspaces` loaded with `require(<absolute path>)` (tracked by Hyprland for auto-reload) from `~/.config/hypr`; matugen `colors.lua` and the settings app's `shellOverrides/main.lua` loaded likewise with a file-exists guard, shipped defaults as fallback |
| `system/programs/hyprland/hyprland/general.lua` | `decoration.shadow.render_power` 10 → 4 (the pinned Hyprland rejects values above 4) |
| `system/programs/hyprland/hyprland/env.lua` | removed `XDG_DATA_DIRS` and `ILLOGICAL_IMPULSE_VIRTUAL_ENV` lines |
| `system/programs/hyprland/hyprland/execs.lua` | removed `qs -c`, geoclue agent and `hypridle` exec lines (services here) |
| `system/programs/hyprland/hyprland/keybinds.lua` | restart-shell bind runs `systemctl --user restart quickshell`; `custom/variables.lua` via `require(<absolute path>)` (tracked by Hyprland for auto-reload); scripts dir is `/etc/xdg/hypr/hyprland/scripts` |
| `system/programs/hyprland/hyprland/variables.lua` | scripts dir is `/etc/xdg/hypr/hyprland/scripts` |
| `home/quickshell/ii/modules/common/widgets/shapes/` | git submodule flattened to plain files (same commit) |
