{
  pkgs,
  lib,
  config,
  theme,
  ...
}:

let
  colors = theme.format.toFootIni theme.palette;

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
  };
in
{
  home = {
    packages = [ pkgs.foot ];

    # Preset palette as a standalone include target. Quickshell points
    # state/foot.ini back here when leaving matugen mode.
    file.".config/foot/colors.ini".text = lib.generators.toINI { } { inherit colors; };

    # `include` must precede any [section]; quickshell-managed state/foot.ini
    # holds either matugen-generated [colors] or an include of colors.ini above.
    file.".config/foot/foot.ini".text = ''
      include = ${config.home.homeDirectory}/.config/quickshell/state/foot.ini
    ''
    + lib.generators.toINI { } settings;
  };
}
