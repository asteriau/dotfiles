{
  config,
  pkgs,
  lib,
  theme,
  ...
}:
let
  cursorName = "Bibata-Modern-Classic-Hyprcursor";
  inherit (theme.format) toHyprlandRgba stripHash;
in
{
  programs.hyprland.settings = {
    "$mod" = "SUPER";

    # Matugen overlay for borders / misc.background_color. Empty in preset
    # mode → static values below win; populated in matugen mode → overrides.
    # ~ is expanded by Hyprland to the user's home at session start.
    source = [ "~/.config/quickshell/state/hyprland.conf" ];

    env = [
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "HYPRCURSOR_THEME,${cursorName}"
      "HYPRCURSOR_SIZE,${toString 16}"
      # See https://github.com/hyprwm/contrib/issues/142
      "GRIMBLAST_NO_CURSOR,0"
    ];

    monitor = [
      "DP-1, 1920x1080@165, 0x0, 1"
    ];

    exec-once = [
      # set cursor for HL itself
      "hyprctl setcursor ${cursorName} ${toString 16}"
    ];

    general = {
      gaps_in = 4;
      gaps_out = 8;
      border_size = 2;
      "col.active_border" = toHyprlandRgba {
        hex = theme.palette.border;
        alpha = "77";
      };
      "col.inactive_border" = toHyprlandRgba {
        hex = theme.palette.surfaceContainerLow;
        alpha = "33";
      };

      allow_tearing = false;
      resize_on_border = true;
    };

    group = {
      groupbar = {
        font_size = 10;
        gradients = false;
        text_color = "rgb(${stripHash theme.palette.m3onPrimaryContainer})";
      };

      "col.border_active" = toHyprlandRgba {
        hex = theme.palette.primaryContainer;
        alpha = "88";
      };
      "col.border_inactive" = toHyprlandRgba {
        hex = theme.palette.m3onPrimaryContainer;
        alpha = "88";
      };
    };

    input = {
      kb_layout = "ro";

      # focus change on cursor move
      follow_mouse = 1;
      accel_profile = "flat";
      tablet.output = "current";
    };

    dwindle = {
      # keep floating dimentions while tiling
      pseudotile = true;
      preserve_split = true;
    };

    misc = {
      force_default_wallpaper = 0;

      background_color = toHyprlandRgba {
        hex = theme.palette.elevated;
        alpha = "FF";
      };

      # disable dragging animation
      animate_mouse_windowdragging = false;

      # enable variable refresh rate (effective depending on hardware)
      vrr = 1;
    };

    render.direct_scanout = false; # this breaks nvidia stuff

    permission = [
      # Allow xdph and grim
      "${config.programs.hyprland.portalPackage}/libexec/.xdg-desktop-portal-hyprland-wrapped, screencopy, allow"
      "${lib.getExe pkgs.grim}, screencopy, allow"
      # Optionally allow non-pipewire capturing
      "${lib.getExe pkgs.wl-screenrec}, screencopy, allow"
    ];

    xwayland.force_zero_scaling = true;

    plugin.hyprbars = {
      bar_height = 20;
      # bar_precedence_over_border = true;
      icon_on_hover = true;
    };

    # order is right-to-left
    hyprbars-button = [
      # close
      "rgb(ffb4ab), 15, , hyprctl dispatch killactive"
      # maximize
      "rgb(b6c4ff), 15, , hyprctl dispatch fullscreen 1"
    ];
  };
}
