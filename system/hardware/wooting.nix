# stuff i need to run wooting drivers cuz wootility is fucky on nix

{ pkgs, ... }:

{
  services.udev.packages = [
    pkgs.wooting-udev-rules
  ];
}
