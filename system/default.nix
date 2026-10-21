let
  desktop = [
    ./core
    ./hardware/bluetooth.nix
    ./hardware/fwupd.nix
    ./hardware/graphics.nix
    ./hardware/tablet.nix
    ./hardware/wooting.nix
    ./network
    ./programs
    ./services
    ./services/power.nix
  ];

  wayland = [
    ./programs/hyprland
    ./services/gnome-services.nix
    ./illogical-impulse.nix
  ];

  gaming = [ ./programs/games.nix ];
in
{
  inherit desktop wayland gaming;
}
