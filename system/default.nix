let
  desktop = [
    ./core

    ./hardware/fwupd.nix
    ./hardware/tablet.nix
    ./hardware/graphics.nix

    ./network

    ./programs

    ./services
    ./services/greetd.nix
    ./services/pipewire.nix
  ];

  laptop = desktop ++ [
    ./hardware/bluetooth.nix

    ./services/backlight.nix
    ./services/power.nix
  ];
in
{
  inherit desktop laptop;
}
