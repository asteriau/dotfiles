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
in
{
  inherit desktop laptop;
}
