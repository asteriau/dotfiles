{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deadnix
    nixfmt
    statix
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
