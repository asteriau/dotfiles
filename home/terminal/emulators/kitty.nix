{ pkgs, lib, ... }:

let
  colors = {
    foreground = "#E8E3E3";
    background = "#151515";

    # Normal colors
    color0 = "#151515"; # black
    color1 = "#B66467"; # red
    color2 = "#8C977D"; # green
    color3 = "#D9BC8C"; # yellow
    color4 = "#8DA3B9"; # blue
    color5 = "#A988B0"; # magenta
    color6 = "#8AA6A2"; # cyan
    color7 = "#E8E3E3"; # white

    # Bright colors
    color8 = "#424242"; # bright black
    color9 = "#B66467"; # bright red
    color10 = "#8C977D"; # bright green
    color11 = "#D9BC8C"; # bright yellow
    color12 = "#8DA3B9"; # bright blue
    color13 = "#A988B0"; # bright magenta
    color14 = "#8AA6A2"; # bright cyan
    color15 = "#E8E3E3"; # bright white

    # Selection
    selection_foreground = "#8DA3B9";
    selection_background = "#151515";

    # URL
    url_color = "#8DA3B9";
  };
in
{
  programs.kitty = {
    enable = true;

    font = {
      size = 14;
      name = "JetBrains Mono Nerd Font";
    };

    settings = {
      scrollback_lines = 10000;
      placement_strategy = "center";

      allow_remote_control = "yes";
      enable_audio_bell = "no";
      visual_bell_duration = "0.1";

      copy_on_select = "clipboard";
      cursor_shape = "beam";

      background_opacity = "1.0";

      # Apply the colors
    }
    // colors;

    # Disable any theme override
    theme = null;
  };
}
