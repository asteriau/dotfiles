-- Theme overlay (matugen mode). Rendered from this template by services/
-- Matugen.qml into ~/.config/quickshell/state/hyprland-colors.lua and loaded
-- by /etc/xdg/hypr/colors.lua. Preset mode is written by services/Theme.qml.
hl.config({
  general = {
    col = {
      active_border = "rgba({{colors.outline_variant.default.hex_stripped}}77)",
      inactive_border = "rgba({{colors.surface_container_low.default.hex_stripped}}33)",
    },
  },
  misc = { background_color = "rgba({{colors.surface.default.hex_stripped}}FF)" },
})
