{
  inputs,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [
    inputs.hyprland.nixosModules.default

    ./animations.nix
    ./binds.nix
    ./decoration.nix
    ./rules.nix
    ./settings.nix
  ];

  environment = {
    systemPackages = [
      inputs.hyprland-contrib.packages.${system}.grimblast
      inputs.self.packages.${system}.bibata-hyprcursor
    ];

    pathsToLink = [ "/share/icons" ];

    # tell Electron/Chromium to run on Wayland
    variables.NIXOS_OZONE_WL = "1";
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
