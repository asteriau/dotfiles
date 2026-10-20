{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # matugen writes this file; home/quickshell/state.nix seeds it empty
        include = "~/.config/fuzzel/fuzzel_theme.ini";
        font = "Google Sans Flex:weight=medium";
        terminal = "foot";
        prompt = ''">>  "'';
        layer = "overlay";
      };

      border = {
        radius = 17;
        width = 1;
      };

      dmenu.exit-immediately-if-empty = "yes";
    };
  };
}
