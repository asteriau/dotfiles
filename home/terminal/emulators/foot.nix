{
  pkgs,
  lib,
  ...
}:
let
  colors = {
    dark = {
      # Base
      foreground = "c6d0f5";
      background = "303446";

      # Cursor
      cursor = "232634 f2d5cf";

      # Normal colors
      regular0 = "51576d";
      regular1 = "e78284";
      regular2 = "a6d189";
      regular3 = "e5c890";
      regular4 = "8caaee";
      regular5 = "f4b8e4";
      regular6 = "81c8be";
      regular7 = "b5bfe2";

      # Bright colors
      bright0 = "626880";
      bright1 = "e78284";
      bright2 = "a6d189";
      bright3 = "e5c890";
      bright4 = "8caaee";
      bright5 = "f4b8e4";
      bright6 = "81c8be";
      bright7 = "a5adce";

      # Selection
      selection-foreground = "c6d0f5";
      selection-background = "4f5369";

      # Search
      search-box-no-match = "232634 e78284";
      search-box-match = "c6d0f5 414559";

      # Misc
      jump-labels = "232634 ef9f76";
      urls = "8caaee";
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
        alpha = 1.0;
      }
      // colors.dark;
    };
  };
}
