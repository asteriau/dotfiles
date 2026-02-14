{
  pkgs,
  lib,
  ...
}:
let
  colors = {
    dark = {
      # Base
      foreground = "cdd6f4";
      background = "1e1e2e";

      # Cursor
      cursor = "11111b f5e0dc";

      # Normal colors
      regular0 = "45475a";
      regular1 = "f38ba8";
      regular2 = "a6e3a1";
      regular3 = "f9e2af";
      regular4 = "89b4fa";
      regular5 = "f5c2e7";
      regular6 = "94e2d5";
      regular7 = "bac2de";

      # Bright colors
      bright0 = "585b70";
      bright1 = "f38ba8";
      bright2 = "a6e3a1";
      bright3 = "f9e2af";
      bright4 = "89b4fa";
      bright5 = "f5c2e7";
      bright6 = "94e2d5";
      bright7 = "a6adc8";

      # Selection
      selection-foreground = "cdd6f4";
      selection-background = "414356";

      # Search
      search-box-no-match = "11111b f38ba8";
      search-box-match = "cdd6f4 313244";

      # Misc
      jump-labels = "11111b fab387";
      urls = "89b4fa";
    };

    light = {
      foreground = "383a42"; # Text
      background = "f9f9f9"; # Base

      regular0 = "000000"; # Surface 1
      regular1 = "e45649"; # red
      regular2 = "50a14f"; # green
      regular3 = "986801"; # yellow
      regular4 = "4078f2"; # blue
      regular5 = "a626a4"; # maroon
      regular6 = "0184bc"; # teal
      regular7 = "a0a1a7"; # Subtext 1

      bright0 = "383a42"; # Surface 2
      bright1 = "e45649"; # red
      bright2 = "50a14f"; # green
      bright3 = "986801"; # yellow
      bright4 = "4078f2"; # blue
      bright5 = "a626a4"; # maroon
      bright6 = "0184bc"; # teal
      bright7 = "ffffff"; # Subtext 0
    };
  };
in
{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        font = "JetBrains Mono Nerd Font:size=14";
        horizontal-letter-offset = 0;
        vertical-letter-offset = 0;
        pad = "4x4 center";
        selection-target = "clipboard";
      };

      bell = {
        urgent = "yes";
        notify = "yes";
      };

      desktop-notifications = {
        command = "${lib.getExe pkgs.libnotify} -a \${app-id} -i \${app-id} \${title} \${body}";
      };

      scrollback = {
        lines = 10000;
        multiplier = 3;
        indicator-position = "relative";
        indicator-format = "line";
      };

      url = {
        launch = "${pkgs.xdg-utils}/bin/xdg-open \${url}";
      };

      cursor = {
        style = "beam";
        beam-thickness = 1;
      };

      colors = {
        alpha = 0.7;
      }
      // colors.dark;
    };
  };
}
