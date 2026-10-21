{ pkgs, ... }:
{
  # wootility needs these to see the keyboard
  services.udev.packages = [ pkgs.wooting-udev-rules ];
}
