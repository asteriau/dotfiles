{ inputs, ... }:
{
  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Static Lua config, same mechanism as main. Runtime-written files
  # (custom/, colors.lua, shellOverrides, monitors.lua) live in ~/.config/hypr
  # and are dofile()d from hyprland.lua.
  environment.etc = {
    "xdg/hypr/hyprland.lua".source = ./hyprland.lua;
    "xdg/hypr/hyprland".source = ./hyprland;
  };
}
