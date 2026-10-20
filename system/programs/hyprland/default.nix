{ inputs, pkgs, ... }:
{
  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Static Lua config, same mechanism as main. Both files are published from one
  # store directory: Hyprland resolves the real path of hyprland.lua and sets
  # Lua's package.path next to it, so hyprland/ must be a real sibling there.
  # Runtime-written files (custom/, colors.lua, shellOverrides, monitors.lua)
  # live in ~/.config/hypr and are require()d from hyprland.lua.
  environment.etc."xdg/hypr".source = pkgs.runCommand "illogical-impulse-hypr" { } ''
    mkdir -p $out
    cp ${./hyprland.lua} $out/hyprland.lua
    cp -r ${./hyprland} $out/hyprland
  '';
}
