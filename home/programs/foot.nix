{ pkgs, lib, ... }:
let
  settings = {
    main = {
      term = "xterm-256color";
      title = "foot";
      font = "JetBrainsMono Nerd Font:size=11";
      letter-spacing = 0;
      dpi-aware = "no";
      pad = "25x25";
      bold-text-in-bright = "no";
    };

    scrollback.lines = 10000;

    cursor = {
      style = "beam";
      blink = "no";
      beam-thickness = 1.5;
    };

    key-bindings = {
      scrollback-up-page = "Page_Up";
      scrollback-down-page = "Page_Down";
      clipboard-copy = "Control+c";
      clipboard-paste = "Control+v";
      search-start = "Control+f";
      font-increase = "Control+plus Control+equal Control+KP_Add";
      font-decrease = "Control+minus Control+KP_Subtract";
      font-reset = "Control+0 Control+KP_0";
    };

    search-bindings = {
      cancel = "Escape";
      find-prev = "Shift+F3";
      find-next = "F3 Control+G";
      delete-prev-word = "Control+BackSpace";
    };

    # Ctrl+Shift+C sends ^C since Ctrl+C is copy above
    text-bindings."\\x03" = "Control+Shift+c";
  };
  colors = "~/.local/state/quickshell/user/generated/terminal/foot.ini";
in
{
  home.packages = [ pkgs.foot ];

  # `include` must come before any section, which programs.foot cannot do.
  # The palette is written by the shell's applycolor.sh so the window opens
  # already coloured instead of flashing the default black.
  xdg.configFile."foot/foot.ini".text = ''
    include=${colors}
  ''
  + lib.generators.toINI { } settings;

  home.activation.footColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -e ${colors} ] || run install -Dm644 /dev/null ${colors}
  '';
}
