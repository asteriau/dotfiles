{
  config,
  pkgs,
  lib,
  ...
}:
let
  # pointer = config.home.pointerCursor;
  cursorName = "Bibata-Modern-Classic-Hyprcursor";
in
{
  programs.hyprland.settings = {
    "$mod" = "SUPER";
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
      "hyprlock"
    ];

    general = {
      gaps_in = 4;
      gaps_out = 8;
      border_size = 1;
      "col.active_border" = "rgba(88888888)";
      "col.inactive_border" = "rgba(88888844)";

      allow_tearing = false;
      resize_on_border = true;
    };

    decoration = {
      rounding = 10;
      rounding_power = 2.5;
      blur = {
        enabled = true;
        brightness = 1.0;
        contrast = 1.0;
        noise = 0.01;

        vibrancy = 0.2;
        vibrancy_darkness = 0.5;

        passes = 4;
        size = 7;

        popups = true;
        popups_ignorealpha = 0.2;
      };

      shadow = {
        enabled = true;
        color = "rgba(00000055)";
        ignore_window = true;
        offset = "0 15";
        range = 100;
        render_power = 2;
        scale = 0.97;
      };
    };

    animations.enabled = true;

    bezier = [
      "expressiveFastSpatial, 0.42, 1.67, 0.21, 0.90"
      "expressiveSlowSpatial, 0.39, 1.29, 0.35, 0.98"
      "expressiveDefaultSpatial, 0.38, 1.21, 0.22, 1.00"
      "emphasizedDecel, 0.05, 0.7, 0.1, 1"
      "emphasizedAccel, 0.3, 0, 0.8, 0.15"
      "standardDecel, 0, 0, 0, 1"
      "menu_decel, 0.1, 1, 0, 1"
      "menu_accel, 0.52, 0.03, 0.72, 0.08"
      "stall, 1, -0.1, 0.7, 0.85"
    ];

    animation = [
      "windowsIn, 1, 3, emphasizedDecel, popin 80%"
      "fadeIn, 1, 3, emphasizedDecel"
      "windowsOut, 1, 2, emphasizedDecel, popin 90%"
      "fadeOut, 1, 2, emphasizedDecel"
      "windowsMove, 1, 3, emphasizedDecel, slide"
      "border, 1, 10, emphasizedDecel"
      "layersIn, 1, 2.7, emphasizedDecel, popin 93%"
      "layersOut, 1, 2.4, menu_accel, popin 94%"
      "fadeLayersIn, 1, 0.5, menu_decel"
      "fadeLayersOut, 1, 2.7, stall"
      "workspaces, 1, 7, menu_decel, slide"
      "specialWorkspaceIn, 1, 2.8, emphasizedDecel, slidevert"
      "specialWorkspaceOut, 1, 1.2, emphasizedAccel, slidevert"
      "zoomFactor, 1, 3, emphasizedDecel"
    ];

    group = {
      groupbar = {
        font_size = 10;
        gradients = false;
        text_color = "rgb(b6c4ff)";
      };

      "col.border_active" = "rgba(35447988)";
      "col.border_inactive" = "rgba(dce1ff88)";
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

      # disable dragging animation
      animate_mouse_windowdragging = false;

      # enable variable refresh rate (effective depending on hardware)
      vrr = 1;
    };

    render.direct_scanout = false;

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
