# Local patches to vendored files

Upstream: end-4/dots-hyprland at the commit in `UPSTREAM`. Every other file
under `dots/` is byte-identical to upstream. When applying an upstream diff,
conflicts can only occur here.

| file | change |
|---|---|
| `.config/quickshell/ii/services/LatexRenderer.qml` | `microtexBinaryDir` from `$MICROTEX_DIR`, upstream default kept |
| `.config/quickshell/ii/services/HyprlandXkb.qml` | `baseLayoutFilePath` from `$ILLOGICAL_IMPULSE_XKB_RULES`, default kept |
| `.config/quickshell/ii/services/Audio.qml` | sounds dir from `$ILLOGICAL_IMPULSE_SOUNDS_DIR`, default kept |
| `.config/hypr/hyprland/env.lua` | removed `XDG_DATA_DIRS` and `ILLOGICAL_IMPULSE_VIRTUAL_ENV` lines (session env provides them) |
| `.config/hypr/hyprland/execs.lua` | removed `qs -c`, geoclue agent and `__restore_video_wallpaper.sh` exec lines |
| `.config/hypr/hyprland/keybinds.lua` | restart-shell bind runs `systemctl --user restart quickshell` |
| `.config/foot/foot.ini` | removed `shell=fish` |
| `.config/quickshell/ii/modules/common/widgets/shapes/` | git submodule flattened to plain files (same commit) |
