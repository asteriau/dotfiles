let
  desktop = [
    ./core

    ./hardware/fwupd.nix
    ./hardware/tablet.nix
    ./hardware/graphics.nix

    ./network

    ./programs

    ./services
  ];

  laptop = desktop ++ [
    ./hardware/bluetooth.nix

    ./services/backlight.nix
    ./services/power.nix
  ];

  gaming = [
    ./programs/gamemode.nix
    ./programs/games.nix
    ./network/spotify.nix
  ];

  wayland = [
    ./programs/hyprland
    ./services/gnome-services.nix
  ];

  wsl = [
    ./core/users.nix
    ./nix
    ./programs/zsh.nix
    ./programs/home-manager.nix
  ];
in
{
  inherit
    desktop
    laptop
    gaming
    wayland
    wsl
    ;
}
