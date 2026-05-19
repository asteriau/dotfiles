{
  config,
  pkgs,
  lib,
  theme,
  ...
}:
let
  inherit (theme.format) toHyprlandRgba stripHash;
in
{
  environment.etc."xdg/hypr/variables.lua".text = ''
    mod = "SUPER"

    cursorName = "Bibata-Modern-Classic-Hyprcursor"
    cursorSize = "16"

    gaps_in = 4
    gaps_out = 8
    border_size = 2

    -- Static theme palette (preset mode). Matugen mode overrides these at
    -- runtime via the overlay handled in colors.lua / hyprland-colors.lua.
    border_active_color = "${
      toHyprlandRgba {
        hex = theme.palette.border;
        alpha = "77";
      }
    }"
    border_inactive_color = "${
      toHyprlandRgba {
        hex = theme.palette.surfaceContainerLow;
        alpha = "33";
      }
    }"
    group_border_active_color = "${
      toHyprlandRgba {
        hex = theme.palette.primaryContainer;
        alpha = "88";
      }
    }"
    group_border_inactive_color = "${
      toHyprlandRgba {
        hex = theme.palette.m3onPrimaryContainer;
        alpha = "88";
      }
    }"
    group_text_color = "rgb(${stripHash theme.palette.m3onPrimaryContainer})"
    background_color = "${
      toHyprlandRgba {
        hex = theme.palette.elevated;
        alpha = "FF";
      }
    }"

    portal_hyprland = "${config.programs.hyprland.portalPackage}/libexec/.xdg-desktop-portal-hyprland-wrapped"
    grim_bin = "${lib.getExe pkgs.grim}"
    wl_screenrec_bin = "${lib.getExe pkgs.wl-screenrec}"
  '';
}
