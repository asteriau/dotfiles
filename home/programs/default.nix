{ pkgs, inputs, ... }:
{
  imports = [
    ./browsers
    ./games.nix
    ./gtk.nix
    ./media
    ./office
    ./qt.nix
    ./wayland
  ];

  home.packages = with pkgs; [
    halloy
    signal-desktop
    vesktop
    # telegram-desktop

    gnome-calculator
    gnome-control-center

    overskride
    resources
    wineWow64Packages.wayland

    zotero

    inputs.nix-matlab.packages.${pkgs.stdenv.hostPlatform.system}.matlab
  ];

  xdg.configFile."matlab/nix.sh".text = "INSTALL_DIR=$XDG_DATA_HOME/matlab/installation_2025b";
}
