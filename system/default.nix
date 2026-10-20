let
  desktop = [
    ./core
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

  wayland = [
    ./programs/hyprland
    ./services/gnome-services.nix
    ./illogical-impulse.nix
  ];
in
{
  inherit desktop laptop wayland;
}
