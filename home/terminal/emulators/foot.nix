{
  pkgs,
  lib,
  config,
  ...
}:

let
  colors = {
    # Base
    background = "151515";
    foreground = "E8E3E3";

    # Normal colors
    regular0 = "151515"; # black
    regular1 = "B66467"; # red
    regular2 = "8C977D"; # green
    regular3 = "D9BC8C"; # yellow
    regular4 = "8DA3B9"; # blue
    regular5 = "A988B0"; # magenta
    regular6 = "8AA6A2"; # cyan
    regular7 = "E8E3E3"; # white

    # Bright colors
    bright0 = "424242"; # bright black
    bright1 = "B66467"; # bright red
    bright2 = "8C977D"; # bright green
    bright3 = "D9BC8C"; # bright yellow
    bright4 = "8DA3B9"; # bright blue
    bright5 = "A988B0"; # bright magenta
    bright6 = "8AA6A2"; # bright cyan
    bright7 = "E8E3E3"; # bright white

    # Selection
    selection-foreground = "8DA3B9";
    selection-background = "151515";

    # Search
    search-box-no-match = "151515 B66467";
    search-box-match = "E8E3E3 151515";

    # Misc
    jump-labels = "151515 8DA3B9";
    urls = "8DA3B9";

    # Opacity
    alpha = 1.0;
  };

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

    colors = colors;
  };
in
{
  home.packages = [ pkgs.foot ];

  # Manage foot.ini directly so we can append an `include` directive at the
  # bottom — Quickshell writes `state/foot.ini` in matugen mode to override
  # [colors]; in preset mode it clears the file so static colors above win.
  home.file.".config/foot/foot.ini".text =
    lib.generators.toINI { } settings
    + ''

      include = ${config.home.homeDirectory}/.config/quickshell/state/foot.ini
    '';
}
