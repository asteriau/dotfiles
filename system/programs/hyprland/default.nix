{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [
    inputs.hyprland.nixosModules.default

    ./variables.nix
  ];

  environment = {
    systemPackages = [
      inputs.hyprland-contrib.packages.${system}.grimblast
      inputs.self.packages.${system}.bibata-hyprcursor
    ];

    pathsToLink = [ "/share/icons" ];

    # tell Electron/Chromium to run on Wayland
    variables.NIXOS_OZONE_WL = "1";

    # write the Lua config (variables.lua is written by ./variables.nix)
    etc =
      let
        lua = [
          ./hyprland.lua
          ./settings.lua
          ./decoration.lua
          ./animations.lua
          ./binds.lua
          ./rules.lua
          ./colors.lua
        ];
      in
      builtins.listToAttrs (
        map (e: {
          name = "xdg/hypr/${lib.baseNameOf e}";
          value.source = e;
        }) lua
      );
  };

  # enable hyprland and required options
  programs.hyprland = {
    enable = true;
    withUWSM = true;

    plugins = with inputs.hyprland-plugins.packages.${system}; [
      # hyprbars
      # hyprexpo
    ];
  };
}
