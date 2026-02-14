{ inputs, ... }:

{
  imports = [
    inputs.aagl.nixosModules.default # Enable launchers for hoyo games
  ];

  nix.settings = inputs.aagl.nixConfig;

  programs = {
    anime-game-launcher.enable = true; # Genshin
    honkers-railway-launcher.enable = true; # HSR
    honkers-launcher.enable = true; # HI3
    wavey-launcher.enable = true; # WuWa
    sleepy-launcher.enable = true; # ZZZ
  };
}
