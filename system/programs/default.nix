{
  imports = [
    ./fonts.nix
    ./home-manager.nix
    ./nix-ld.nix
    ./xdg.nix
  ];

  programs.dconf.enable = true;
}
