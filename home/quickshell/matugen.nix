{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };

  # Paths are the ones upstream's scripts (switchwall.sh) expect.
  template = name: output: {
    input_path = "~/.config/matugen/templates/${name}";
    output_path = output;
  };
in
{
  xdg.configFile = {
    "matugen/config.toml".source = tomlFormat.generate "matugen-config.toml" {
      config.version_check = false;
      templates = {
        m3colors = template "colors.json" "~/.local/state/quickshell/user/generated/colors.json";
        hyprland = template "hyprland/colors.lua" "~/.config/hypr/hyprland/colors.lua";
        hyprlock = template "hyprland/hyprlock-colors.conf" "~/.config/hypr/hyprlock/colors.conf";
        fuzzel = template "fuzzel/fuzzel_theme.ini" "~/.config/fuzzel/fuzzel_theme.ini";
        gtk3 = template "gtk-3.0/gtk.css" "~/.config/gtk-3.0/gtk.css";
        gtk4 = template "gtk-4.0/gtk.css" "~/.config/gtk-4.0/gtk.css";
        kde_colors = template "kde/color.txt" "~/.local/state/quickshell/user/generated/color.txt";
        wallpaper = template "wallpaper.txt" "~/.local/state/quickshell/user/generated/wallpaper/path.txt";
      };
    };

    # template assets (upstream dots/.config/matugen/templates); the kde/ wrapper
    # script in there is called by switchwall.sh
    "matugen/templates".source = ./matugen/templates;
  };
}
