{ lib }:
let
  stripHash = lib.strings.removePrefix "#";

  derivedAnsi = palette: {
    black = stripHash palette.surfaceContainerLowest;
    red = stripHash palette.red;
    green = stripHash palette.mpris;
    yellow = stripHash palette.accent;
    blue = stripHash palette.accent;
    magenta = stripHash palette.primaryContainer;
    cyan = stripHash palette.mpris;
    white = stripHash palette.foreground;
    brightBlack = stripHash palette.surfaceContainerHigh;
    brightRed = stripHash palette.red;
    brightGreen = stripHash palette.mpris;
    brightYellow = stripHash palette.accent;
    brightBlue = stripHash palette.accent;
    brightMagenta = stripHash palette.primaryContainer;
    brightCyan = stripHash palette.mpris;
    brightWhite = stripHash palette.foreground;
  };
in
rec {
  inherit stripHash;

  toHyprlandRgba =
    {
      hex,
      alpha ? "FF",
    }:
    "rgba(${stripHash hex}${alpha})";

  toFootIni =
    palette:
    let
      ansi = if palette ? _ansi then lib.mapAttrs (_: stripHash) palette._ansi else derivedAnsi palette;
    in
    {
      background = stripHash palette.background;
      foreground = stripHash palette.foreground;
      regular0 = ansi.black;
      regular1 = ansi.red;
      regular2 = ansi.green;
      regular3 = ansi.yellow;
      regular4 = ansi.blue;
      regular5 = ansi.magenta;
      regular6 = ansi.cyan;
      regular7 = ansi.white;
      bright0 = ansi.brightBlack;
      bright1 = ansi.brightRed;
      bright2 = ansi.brightGreen;
      bright3 = ansi.brightYellow;
      bright4 = ansi.brightBlue;
      bright5 = ansi.brightMagenta;
      bright6 = ansi.brightCyan;
      bright7 = ansi.brightWhite;
    };

  toGtkColors = palette: ''
    @define-color theme_bg_color ${palette.background};
    @define-color theme_fg_color ${palette.foreground};
    @define-color theme_base_color ${palette.surfaceContainer};
    @define-color theme_text_color ${palette.foreground};
    @define-color theme_selected_bg_color ${palette.accent};
    @define-color theme_selected_fg_color ${palette.m3onPrimary};
    @define-color borders ${palette.m3outline};
    @define-color warning_color ${palette.accent};
    @define-color error_color ${palette.red};
    @define-color success_color ${palette.mpris};
    @define-color accent_color ${palette.accent};
    @define-color accent_bg_color ${palette.accent};
    @define-color accent_fg_color ${palette.m3onPrimary};
    @define-color window_bg_color ${palette.background};
    @define-color window_fg_color ${palette.foreground};
    @define-color view_bg_color ${palette.surfaceContainer};
    @define-color view_fg_color ${palette.foreground};
    @define-color headerbar_bg_color ${palette.surfaceContainerHigh};
    @define-color headerbar_fg_color ${palette.foreground};
    @define-color card_bg_color ${palette.surfaceContainerHigh};
    @define-color card_fg_color ${palette.foreground};
    @define-color popover_bg_color ${palette.surfaceContainerHigh};
    @define-color popover_fg_color ${palette.foreground};
  '';

  toQtPalette =
    palette:
    let
      c = palette;
      active = lib.concatStringsSep ", " [
        c.foreground
        c.background
        c.elevated
        c.surfaceContainerHigh
        c.surfaceContainerHighest
        c.surfaceContainerLow
        c.foreground
        c.surfaceContainer
        c.foreground
        c.background
        c.surfaceContainerLow
        c.background
        c.accent
        c.m3onPrimary
        c.accent
        c.accent
        c.background
        c.foreground
        c.surfaceContainerLow
        c.foreground
        c.red
      ];
      disabled = lib.concatStringsSep ", " [
        c.m3onSurfaceVariant
        c.background
        c.elevated
        c.surfaceContainerHigh
        c.surfaceContainerHighest
        c.surfaceContainerLow
        c.m3onSurfaceVariant
        c.surfaceContainer
        c.m3onSurfaceVariant
        c.background
        c.surfaceContainerLow
        c.background
        c.accentContainer
        c.accentContainerText
        c.accent
        c.accent
        c.background
        c.m3onSurfaceVariant
        c.surfaceContainerLow
        c.m3onSurfaceVariant
        c.red
      ];
      inactive = active;
    in
    ''
      [ColorScheme]
      active_colors=${active}
      disabled_colors=${disabled}
      inactive_colors=${inactive}
    '';
}
