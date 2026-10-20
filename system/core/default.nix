{ lib, ... }:
{
  imports = [
    ./boot.nix
    ./security.nix
    ./users.nix
    ../nix
    ../programs/fish.nix
  ];

  documentation.dev.enable = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "ro_RO.UTF-8/UTF-8"
    ];
  };

  system.stateVersion = lib.mkDefault "23.11";

  time.timeZone = lib.mkDefault "Europe/Bucharest";

  zramSwap.enable = true;
}
