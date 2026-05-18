{
  imports = [
    ./fonts.nix
    ./home-manager.nix
    ./nix-ld.nix
    ./xdg.nix
  ];

  programs = {
    # make HM-managed GTK stuff work
    dconf.enable = true;

    kdeconnect.enable = true;

    seahorse.enable = true;
  };
}
