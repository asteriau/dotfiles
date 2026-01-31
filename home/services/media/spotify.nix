{ pkgs, ... }:
{
  home.packages = [ pkgs.spotify ];

  services.spotify.enable = true;
}
